/**
 * SatApp Agent Chat — Standalone Floating Overlay
 *
 * Connects to the satapp FastAPI backend via WebSocket and provides
 * a real-time chat interface with the SatApp AI agent.
 *
 * WebSocket is proxied through the QWC2 nginx gateway:
 *   /satapp/ws/chat -> host:8000/ws/chat
 *
 * This is a vanilla JS IIFE — no React, no framework dependencies.
 * Exposes window.SatAppChat for the overlay loader.
 */
(function () {
    "use strict";

    var WS_PATH = "/satapp/ws/chat";
    var RECONNECT_DELAY = 3000;
    var MAX_RECONNECT_DELAY = 30000;

    /* ---- state ---- */
    var ws = null;
    var reconnectTimer = null;
    var reconnectDelay = RECONNECT_DELAY;
    var status = "disconnected"; // connected | connecting | disconnected
    var panelOpen = false;
    var messages = [
        { id: "1", sender: "agent", text: "Hello! I am SatAppAI. How can I help you today?" }
    ];

    /* ---- DOM refs (created lazily) ---- */
    var panel, header, statusDot, statusLabel, messageList, inputField, sendBtn;

    /* ---- helpers ---- */
    function el(tag, cls, attrs) {
        var node = document.createElement(tag);
        if (cls) node.className = cls;
        if (attrs) {
            Object.keys(attrs).forEach(function (k) {
                if (k === "textContent") { node.textContent = attrs[k]; }
                else { node.setAttribute(k, attrs[k]); }
            });
        }
        return node;
    }

    function scrollToBottom() {
        if (messageList) {
            messageList.scrollTop = messageList.scrollHeight;
        }
    }

    /* ---- render a single message ---- */
    function renderMessage(msg) {
        var div = el("div", "satapp-msg satapp-msg-" + msg.sender);
        if (msg.sender === "status") {
            div.className = "satapp-msg satapp-msg-status";
        }
        div.textContent = msg.text;
        return div;
    }

    function appendMessage(msg) {
        messages.push(msg);
        if (messageList) {
            messageList.appendChild(renderMessage(msg));
            scrollToBottom();
        }
    }

    /* ---- status indicator ---- */
    function setStatus(s) {
        status = s;
        if (statusDot) {
            statusDot.className = "satapp-status-dot satapp-status-" + s;
        }
        if (statusLabel) {
            statusLabel.textContent =
                s === "connected"    ? "Connected to Mission Control" :
                s === "connecting"   ? "Connecting\u2026" :
                                       "Disconnected";
        }
    }

    /* ---- WebSocket ---- */
    function connect() {
        if (ws) {
            try { ws.close(); } catch (_) { /* ignore */ }
        }

        setStatus("connecting");

        var protocol = location.protocol === "https:" ? "wss:" : "ws:";
        var wsUrl = protocol + "//" + location.host + WS_PATH;

        try {
            ws = new WebSocket(wsUrl);
        } catch (e) {
            setStatus("disconnected");
            scheduleReconnect();
            return;
        }

        ws.onopen = function () {
            setStatus("connected");
            reconnectDelay = RECONNECT_DELAY; // reset back-off
        };

        ws.onmessage = function (event) {
            var data = event.data;
            var text = data;
            var sender = "agent";

            // Try to parse structured messages
            try {
                var parsed = JSON.parse(data);
                if (parsed && parsed.type) {
                    if (parsed.type === "status") {
                        sender = "status";
                    } else if (parsed.type === "error") {
                        sender = "error";
                    }
                    text = parsed.content || data;
                }
            } catch (_) {
                // plain text — use as-is
            }

            appendMessage({
                id: Date.now().toString(),
                sender: sender,
                text: text
            });
        };

        ws.onclose = function () {
            setStatus("disconnected");
            scheduleReconnect();
        };

        ws.onerror = function () {
            // onclose fires after onerror
        };
    }

    function scheduleReconnect() {
        if (reconnectTimer) clearTimeout(reconnectTimer);
        reconnectTimer = setTimeout(function () {
            connect();
        }, reconnectDelay);
        // exponential back-off capped at MAX
        reconnectDelay = Math.min(reconnectDelay * 1.5, MAX_RECONNECT_DELAY);
    }

    /* ---- send ---- */
    function sendMessage() {
        var text = (inputField.value || "").trim();
        if (!text) return;

        appendMessage({
            id: Date.now().toString(),
            sender: "user",
            text: text
        });

        if (ws && ws.readyState === WebSocket.OPEN) {
            ws.send(text);
        } else {
            appendMessage({
                id: (Date.now() + 1).toString(),
                sender: "status",
                text: "Connection lost. Attempting to reconnect\u2026"
            });
        }

        inputField.value = "";
        inputField.focus();
    }

    /* ---- build DOM ---- */
    function buildPanel() {
        panel = el("div", "satapp-chat-panel satapp-overlay-panel");
        panel.id = "satapp-chat-panel";

        // Header (draggable)
        header = el("div", "satapp-overlay-header satapp-chat-header");

        var titleWrap = el("div", "satapp-overlay-header-title");

        statusDot = el("span", "satapp-status-dot satapp-status-disconnected");
        statusLabel = el("span", "satapp-overlay-header-text");
        statusLabel.textContent = "Disconnected";

        titleWrap.appendChild(statusDot);
        titleWrap.appendChild(statusLabel);

        var closeBtn = el("button", "satapp-overlay-close");
        closeBtn.innerHTML = "&times;";
        closeBtn.title = "Close";
        closeBtn.addEventListener("click", function () {
            toggle(false);
        });

        header.appendChild(titleWrap);
        header.appendChild(closeBtn);

        // Messages area
        messageList = el("div", "satapp-chat-messages");
        messages.forEach(function (msg) {
            messageList.appendChild(renderMessage(msg));
        });

        // Input bar
        var inputBar = el("div", "satapp-chat-input");

        inputField = el("input", "", {
            type: "text",
            placeholder: "Type a message\u2026",
            autocomplete: "off"
        });
        inputField.addEventListener("keydown", function (e) {
            if (e.key === "Enter") {
                sendMessage();
            }
        });

        sendBtn = el("button", "");
        sendBtn.textContent = "\u2191";
        sendBtn.title = "Send";
        sendBtn.addEventListener("click", sendMessage);

        inputBar.appendChild(inputField);
        inputBar.appendChild(sendBtn);

        panel.appendChild(header);
        panel.appendChild(messageList);
        panel.appendChild(inputBar);

        // Drag support
        enableDrag(panel, header);

        document.body.appendChild(panel);
    }

    /* ---- drag ---- */
    function enableDrag(panelEl, handleEl) {
        var dragging = false;
        var startX, startY, origLeft, origTop;

        handleEl.style.cursor = "grab";

        handleEl.addEventListener("mousedown", function (e) {
            if (e.target.closest(".satapp-overlay-close")) return;
            dragging = true;
            handleEl.style.cursor = "grabbing";
            startX = e.clientX;
            startY = e.clientY;
            var rect = panelEl.getBoundingClientRect();
            origLeft = rect.left;
            origTop = rect.top;
            e.preventDefault();
        });

        document.addEventListener("mousemove", function (e) {
            if (!dragging) return;
            var dx = e.clientX - startX;
            var dy = e.clientY - startY;
            panelEl.style.left = (origLeft + dx) + "px";
            panelEl.style.top = (origTop + dy) + "px";
            panelEl.style.right = "auto";
            panelEl.style.bottom = "auto";
        });

        document.addEventListener("mouseup", function () {
            if (dragging) {
                dragging = false;
                handleEl.style.cursor = "grab";
            }
        });
    }

    /* ---- toggle ---- */
    function toggle(forceState) {
        var open = typeof forceState === "boolean" ? forceState : !panelOpen;
        panelOpen = open;
        if (panel) {
            panel.style.display = open ? "flex" : "none";
        }
        if (open) {
            // Connect on first open (lazy init)
            if (!ws && status === "disconnected") {
                connect();
            }
            if (messageList) {
                scrollToBottom();
                if (inputField) inputField.focus();
            }
        }
        // Notify loader to update FAB state
        if (window.SatAppOverlay && window.SatAppOverlay._onToggle) {
            window.SatAppOverlay._onToggle("chat", open);
        }
    }

    /* ---- public API ---- */
    window.SatAppChat = {
        init: function () {
            buildPanel();
            // WS connects lazily on first toggle open
            panel.style.display = "none";
        },
        toggle: toggle,
        isOpen: function () { return panelOpen; },
        destroy: function () {
            if (reconnectTimer) clearTimeout(reconnectTimer);
            if (ws) { try { ws.close(); } catch (_) { /* ignore */ } }
            if (panel && panel.parentNode) panel.parentNode.removeChild(panel);
        }
    };
})();
