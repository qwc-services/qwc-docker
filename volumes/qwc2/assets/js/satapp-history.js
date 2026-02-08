/**
 * SatApp Search History — Standalone Floating Overlay
 *
 * Fetches and displays the last 20 searches from the satapp
 * FastAPI backend, auto-refreshing every 30 seconds.
 *
 * REST API is proxied through the QWC2 nginx gateway:
 *   /satapp/api/history -> host:8000/api/history
 *
 * Vanilla JS IIFE — no React, no framework dependencies.
 * Exposes window.SatAppHistory for the overlay loader.
 */
(function () {
    "use strict";

    var API_BASE = "/satapp";
    var REFRESH_INTERVAL = 30000;

    /* ---- state ---- */
    var panelOpen = false;
    var historyData = [];
    var loading = true;
    var error = null;
    var refreshTimer = null;

    /* ---- DOM refs ---- */
    var panel, header, contentArea;

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

    function parseQuery(entry) {
        try {
            var parsed = JSON.parse(entry.query_json);
            return parsed.query || parsed.text || entry.query_json;
        } catch (e) {
            return entry.query_json || "Unknown query";
        }
    }

    function formatDate(dateStr) {
        try {
            return new Date(dateStr).toLocaleString();
        } catch (e) {
            return dateStr;
        }
    }

    /* ---- fetch history ---- */
    function fetchHistory() {
        fetch(API_BASE + "/api/history?limit=20")
            .then(function (res) {
                if (!res.ok) throw new Error("HTTP " + res.status);
                return res.json();
            })
            .then(function (data) {
                historyData = data.history || [];
                loading = false;
                error = null;
                renderContent();
            })
            .catch(function (err) {
                error = "Could not load history: " + err.message;
                loading = false;
                renderContent();
            });
    }

    /* ---- render content area ---- */
    function renderContent() {
        if (!contentArea) return;

        // clear
        contentArea.innerHTML = "";

        // error banner (if data also exists, show both)
        if (error && historyData.length === 0) {
            var errP = el("p", "satapp-error");
            errP.textContent = error;
            contentArea.appendChild(errP);
            return;
        }

        if (loading && historyData.length === 0) {
            var loadP = el("p", "satapp-history-empty");
            loadP.textContent = "Loading history\u2026";
            contentArea.appendChild(loadP);
            return;
        }

        if (historyData.length === 0) {
            var emptyP = el("p", "satapp-history-empty");
            emptyP.textContent = "No searches yet. Use the chat to start a mission.";
            contentArea.appendChild(emptyP);
            return;
        }

        if (error) {
            var errTop = el("p", "satapp-error");
            errTop.textContent = error;
            contentArea.appendChild(errTop);
        }

        historyData.forEach(function (entry) {
            var card = el("div", "satapp-history-entry");

            var query = el("p", "satapp-history-query");
            query.textContent = parseQuery(entry);

            var date = el("span", "satapp-history-date");
            date.textContent = formatDate(entry.searched_at);

            card.appendChild(query);
            card.appendChild(date);
            contentArea.appendChild(card);
        });
    }

    /* ---- build DOM ---- */
    function buildPanel() {
        panel = el("div", "satapp-history-panel satapp-overlay-panel");
        panel.id = "satapp-history-panel";

        // Header
        header = el("div", "satapp-overlay-header satapp-history-header");

        var titleWrap = el("div", "satapp-overlay-header-title");
        var titleIcon = el("span", "satapp-overlay-header-icon");
        titleIcon.textContent = "\uD83D\uDD50"; // clock emoji
        var titleText = el("span", "satapp-overlay-header-text");
        titleText.textContent = "Search History";
        titleWrap.appendChild(titleIcon);
        titleWrap.appendChild(titleText);

        var closeBtn = el("button", "satapp-overlay-close");
        closeBtn.innerHTML = "&times;";
        closeBtn.title = "Close";
        closeBtn.addEventListener("click", function () {
            toggle(false);
        });

        header.appendChild(titleWrap);
        header.appendChild(closeBtn);

        // Content area
        contentArea = el("div", "satapp-history-container");

        panel.appendChild(header);
        panel.appendChild(contentArea);

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
            fetchHistory(); // refresh on open
        }
        // Notify loader to update FAB state
        if (window.SatAppOverlay && window.SatAppOverlay._onToggle) {
            window.SatAppOverlay._onToggle("history", open);
        }
    }

    /* ---- public API ---- */
    window.SatAppHistory = {
        init: function () {
            buildPanel();
            fetchHistory();
            refreshTimer = setInterval(fetchHistory, REFRESH_INTERVAL);
            // start hidden
            panel.style.display = "none";
        },
        toggle: toggle,
        isOpen: function () { return panelOpen; },
        destroy: function () {
            if (refreshTimer) clearInterval(refreshTimer);
            if (panel && panel.parentNode) panel.parentNode.removeChild(panel);
        }
    };
})();
