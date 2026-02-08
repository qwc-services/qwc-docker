/**
 * SatApp Overlay Loader
 *
 * Creates the FAB button bar (bottom-right) and initializes the
 * chat and history overlay panels.
 *
 * Load order:
 *   1. satapp-chat.js      (defines window.SatAppChat)
 *   2. satapp-history.js   (defines window.SatAppHistory)
 *   3. satapp-overlay-loader.js  (this file — wires everything up)
 */
(function () {
    "use strict";

    var fabBar, chatBtn, historyBtn;

    /* ---- inject overlay styles ---- */
    function injectStyles() {
        var css = [
            /* -- Overlay panels (shared) -- */
            ".satapp-overlay-panel {",
            "  position: fixed;",
            "  z-index: 10001;",
            "  display: flex;",
            "  flex-direction: column;",
            "  background: rgba(15, 23, 42, 0.95);",
            "  border: 1px solid rgba(255, 255, 255, 0.12);",
            "  border-radius: 16px;",
            "  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.5);",
            "  backdrop-filter: blur(16px);",
            "  -webkit-backdrop-filter: blur(16px);",
            "  overflow: hidden;",
            "  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;",
            "  color: #f1f5f9;",
            "  transition: opacity 0.2s, transform 0.2s;",
            "}",
            "",
            /* -- Chat panel sizing -- */
            ".satapp-chat-panel {",
            "  right: 24px;",
            "  bottom: 88px;",
            "  width: 380px;",
            "  height: 500px;",
            "}",
            "",
            /* -- History panel sizing -- */
            ".satapp-history-panel {",
            "  right: 420px;",
            "  bottom: 88px;",
            "  width: 350px;",
            "  height: 400px;",
            "}",
            "",
            /* -- Panel header -- */
            ".satapp-overlay-header {",
            "  display: flex;",
            "  align-items: center;",
            "  justify-content: space-between;",
            "  padding: 12px 16px;",
            "  background: rgba(30, 41, 59, 0.9);",
            "  border-bottom: 1px solid rgba(255, 255, 255, 0.1);",
            "  flex-shrink: 0;",
            "  user-select: none;",
            "}",
            "",
            ".satapp-overlay-header-title {",
            "  display: flex;",
            "  align-items: center;",
            "  gap: 8px;",
            "  font-size: 13px;",
            "  color: #94a3b8;",
            "}",
            "",
            ".satapp-overlay-header-icon {",
            "  font-size: 15px;",
            "}",
            "",
            ".satapp-overlay-header-text {",
            "  font-size: 13px;",
            "}",
            "",
            ".satapp-overlay-close {",
            "  background: none;",
            "  border: none;",
            "  color: #64748b;",
            "  font-size: 20px;",
            "  cursor: pointer;",
            "  padding: 0 4px;",
            "  line-height: 1;",
            "  border-radius: 4px;",
            "  transition: color 0.15s, background 0.15s;",
            "}",
            ".satapp-overlay-close:hover {",
            "  color: #f1f5f9;",
            "  background: rgba(255, 255, 255, 0.1);",
            "}",
            "",
            /* -- Chat messages -- */
            ".satapp-chat-messages {",
            "  flex: 1;",
            "  overflow-y: auto;",
            "  padding: 16px;",
            "  display: flex;",
            "  flex-direction: column;",
            "  gap: 8px;",
            "}",
            "",
            ".satapp-msg {",
            "  max-width: 80%;",
            "  padding: 10px 16px;",
            "  border-radius: 16px;",
            "  font-size: 14px;",
            "  line-height: 1.5;",
            "  word-wrap: break-word;",
            "}",
            ".satapp-msg-user {",
            "  background: #3b82f6;",
            "  color: white;",
            "  align-self: flex-end;",
            "  border-bottom-right-radius: 4px;",
            "}",
            ".satapp-msg-agent {",
            "  background: rgba(30, 41, 59, 0.8);",
            "  color: #f1f5f9;",
            "  border: 1px solid rgba(51, 65, 85, 0.8);",
            "  align-self: flex-start;",
            "  border-bottom-left-radius: 4px;",
            "}",
            ".satapp-msg-status {",
            "  background: rgba(51, 65, 85, 0.4);",
            "  color: #94a3b8;",
            "  font-size: 12px;",
            "  font-style: italic;",
            "  align-self: center;",
            "  border-radius: 8px;",
            "  padding: 6px 14px;",
            "}",
            ".satapp-msg-error {",
            "  background: rgba(127, 29, 29, 0.4);",
            "  color: #fca5a5;",
            "  font-size: 12px;",
            "  align-self: center;",
            "  border-radius: 8px;",
            "  padding: 6px 14px;",
            "  border: 1px solid rgba(248, 113, 113, 0.3);",
            "}",
            "",
            /* -- Chat input -- */
            ".satapp-chat-input {",
            "  display: flex;",
            "  gap: 8px;",
            "  padding: 12px;",
            "  border-top: 1px solid rgba(255, 255, 255, 0.1);",
            "  background: rgba(30, 41, 59, 0.5);",
            "  flex-shrink: 0;",
            "}",
            ".satapp-chat-input input {",
            "  flex: 1;",
            "  background: rgba(51, 65, 85, 1);",
            "  border: 1px solid rgba(71, 85, 105, 1);",
            "  border-radius: 9999px;",
            "  padding: 8px 16px;",
            "  color: white;",
            "  font-size: 14px;",
            "  outline: none;",
            "}",
            ".satapp-chat-input input:focus {",
            "  border-color: #60a5fa;",
            "  box-shadow: 0 0 0 2px rgba(96, 165, 250, 0.3);",
            "}",
            ".satapp-chat-input input::placeholder {",
            "  color: #64748b;",
            "}",
            ".satapp-chat-input button {",
            "  width: 36px;",
            "  height: 36px;",
            "  border-radius: 50%;",
            "  background: #3b82f6;",
            "  color: white;",
            "  border: none;",
            "  cursor: pointer;",
            "  font-size: 16px;",
            "  display: flex;",
            "  align-items: center;",
            "  justify-content: center;",
            "  flex-shrink: 0;",
            "}",
            ".satapp-chat-input button:hover { background: #2563eb; }",
            ".satapp-chat-input button:disabled { background: rgba(51,65,85,1); cursor: not-allowed; }",
            "",
            /* -- Status dot -- */
            ".satapp-status-dot {",
            "  display: inline-block;",
            "  width: 8px;",
            "  height: 8px;",
            "  border-radius: 50%;",
            "  flex-shrink: 0;",
            "}",
            ".satapp-status-connected { background: #4ade80; }",
            ".satapp-status-connecting { background: #facc15; animation: satapp-pulse 1s infinite; }",
            ".satapp-status-disconnected { background: #f87171; }",
            "",
            /* -- History container inside panel -- */
            ".satapp-history-panel .satapp-history-container {",
            "  flex: 1;",
            "  padding: 12px;",
            "  overflow-y: auto;",
            "}",
            ".satapp-history-entry {",
            "  padding: 10px 12px;",
            "  background: rgba(30, 41, 59, 0.5);",
            "  border: 1px solid rgba(51, 65, 85, 0.8);",
            "  border-radius: 12px;",
            "  margin-bottom: 8px;",
            "  cursor: pointer;",
            "  transition: background 0.15s;",
            "}",
            ".satapp-history-entry:hover { background: rgba(51, 65, 85, 0.5); }",
            ".satapp-history-query {",
            "  color: white;",
            "  font-size: 14px;",
            "  margin: 0 0 4px 0;",
            "  line-height: 1.4;",
            "}",
            ".satapp-history-date { font-size: 11px; color: #64748b; }",
            ".satapp-history-empty { color: #64748b; font-size: 13px; text-align: center; padding: 24px 12px; }",
            ".satapp-error { color: #f87171; font-size: 12px; padding: 8px; }",
            "",
            /* -- FAB button bar -- */
            ".satapp-fab-bar {",
            "  position: fixed;",
            "  bottom: 24px;",
            "  right: 24px;",
            "  z-index: 10002;",
            "  display: flex;",
            "  gap: 12px;",
            "  align-items: center;",
            "}",
            ".satapp-fab {",
            "  width: 48px;",
            "  height: 48px;",
            "  border-radius: 50%;",
            "  border: 1px solid rgba(255, 255, 255, 0.15);",
            "  background: rgba(15, 23, 42, 0.9);",
            "  backdrop-filter: blur(12px);",
            "  -webkit-backdrop-filter: blur(12px);",
            "  color: #94a3b8;",
            "  font-size: 20px;",
            "  cursor: pointer;",
            "  display: flex;",
            "  align-items: center;",
            "  justify-content: center;",
            "  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.4);",
            "  transition: background 0.2s, color 0.2s, transform 0.15s, box-shadow 0.2s;",
            "}",
            ".satapp-fab:hover {",
            "  background: rgba(30, 41, 59, 0.95);",
            "  color: #f1f5f9;",
            "  transform: scale(1.08);",
            "}",
            ".satapp-fab.active {",
            "  background: #3b82f6;",
            "  color: white;",
            "  border-color: #60a5fa;",
            "  box-shadow: 0 4px 20px rgba(59, 130, 246, 0.4);",
            "}",
            "",
            /* -- Scrollbar for overlay panels -- */
            ".satapp-overlay-panel ::-webkit-scrollbar { width: 6px; }",
            ".satapp-overlay-panel ::-webkit-scrollbar-track { background: transparent; }",
            ".satapp-overlay-panel ::-webkit-scrollbar-thumb {",
            "  background: rgba(100, 116, 139, 0.4);",
            "  border-radius: 3px;",
            "}",
            ".satapp-overlay-panel ::-webkit-scrollbar-thumb:hover {",
            "  background: rgba(100, 116, 139, 0.7);",
            "}",
            "",
            /* -- Animations -- */
            "@keyframes satapp-pulse {",
            "  0%, 100% { opacity: 1; }",
            "  50% { opacity: 0.5; }",
            "}",
            "",
            /* -- Mobile responsive -- */
            "@media (max-width: 640px) {",
            "  .satapp-chat-panel,",
            "  .satapp-history-panel {",
            "    left: 8px !important;",
            "    right: 8px !important;",
            "    bottom: 80px !important;",
            "    width: auto !important;",
            "    max-height: 70vh;",
            "  }",
            "  .satapp-history-panel {",
            "    bottom: 80px !important;",
            "  }",
            "  .satapp-fab-bar {",
            "    right: 16px;",
            "    bottom: 16px;",
            "  }",
            "}"
        ].join("\n");

        var style = document.createElement("style");
        style.id = "satapp-overlay-styles";
        style.textContent = css;
        document.head.appendChild(style);
    }

    /* ---- build FAB bar ---- */
    function buildFabBar() {
        fabBar = document.createElement("div");
        fabBar.className = "satapp-fab-bar";
        fabBar.id = "satapp-fab-bar";

        // History button (left)
        historyBtn = document.createElement("button");
        historyBtn.className = "satapp-fab";
        historyBtn.id = "satapp-fab-history";
        historyBtn.title = "Search History";
        historyBtn.textContent = "\uD83D\uDD50"; // clock emoji
        historyBtn.addEventListener("click", function () {
            if (window.SatAppHistory) window.SatAppHistory.toggle();
        });

        // Chat button (right)
        chatBtn = document.createElement("button");
        chatBtn.className = "satapp-fab";
        chatBtn.id = "satapp-fab-chat";
        chatBtn.title = "Chat with SatApp AI";
        chatBtn.textContent = "\uD83D\uDCAC"; // speech bubble emoji
        chatBtn.addEventListener("click", function () {
            if (window.SatAppChat) window.SatAppChat.toggle();
        });

        fabBar.appendChild(historyBtn);
        fabBar.appendChild(chatBtn);
        document.body.appendChild(fabBar);
    }

    /* ---- callback from panels when they toggle ---- */
    function onToggle(which, open) {
        if (which === "chat" && chatBtn) {
            chatBtn.classList.toggle("active", open);
        } else if (which === "history" && historyBtn) {
            historyBtn.classList.toggle("active", open);
        }
    }

    /* ---- init ---- */
    function init() {
        injectStyles();
        buildFabBar();

        // Load chat and history scripts, then init
        loadScript("assets/js/satapp-chat.js", function () {
            if (window.SatAppChat) window.SatAppChat.init();
        });
        loadScript("assets/js/satapp-history.js", function () {
            if (window.SatAppHistory) window.SatAppHistory.init();
        });
    }

    function loadScript(src, onload) {
        var s = document.createElement("script");
        s.src = src;
        s.onload = onload;
        s.onerror = function () {
            console.error("[SatAppOverlay] Failed to load " + src);
        };
        document.head.appendChild(s);
    }

    /* ---- public API ---- */
    window.SatAppOverlay = {
        _onToggle: onToggle
    };

    /* ---- boot ---- */
    if (document.readyState === "complete" || document.readyState === "interactive") {
        setTimeout(init, 0);
    } else {
        document.addEventListener("DOMContentLoaded", init);
    }
})();
