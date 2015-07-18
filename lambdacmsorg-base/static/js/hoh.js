!function(e) {
    function t(a) {
        if (n[a])
            return n[a].exports;
        var o = n[a] = {
            exports: {},
            id: a,
            loaded: !1
        };
        return e[a].call(o.exports, o, o.exports, t), o.loaded=!0, o.exports
    }
    var n = {};
    return t.m = e, t.c = n, t.p = "", t(0)
}([function(e, t, n) {
    "use strict";
    window.easeScroll = n(1), window.cannot = n(2)
}, function(e, t, n) {
    "use strict";
    var a = n(3).ease;
    t.tween = function(e, t, n, o, i, c) {
        var l = Math.max(0, Math.min(n, t)), s = l - e, r = Date.now(), d = r + o, u = function() {
            if (Date.now() >= d)
                i(l), c && c();
            else {
                var t = (Date.now() - r) / o, n = e + s * a(t);
                i(n), requestAnimationFrame(u)
            }
        };
        requestAnimationFrame(u)
    }, function() {
        t.scrollToOffset = function(e, n, a) {
            if (void 0 === e)
                throw new Error("missing scroll offset");
            void 0 === n && (n = 500);
            var o = scrollY, i = document.body.scrollHeight - innerHeight;
            t.tween(o, i, e, n, function(e) {
                scrollTo(scrollX, e)
            }, a)
        }, t.scrollElementByIdToHorizontalOffset = function(e, n, a, o) {
            var i = document.getElementById(e);
            if (!i)
                throw new Error("missing element");
            if (void 0 === n)
                throw new Error("missing scroll offset");
            void 0 === a && (a = 500);
            var c = i.scrollLeft, l = i.scrollWidth - i.clientWidth;
            t.tween(c, l, n, a, function(e) {
                i.scrollLeft = e
            }, o)
        }
    }(), t.getElementOffsetById = function(e) {
        var t = document.getElementById(e);
        if (!t)
            return void 0;
        var n = 0;
        do 
            n += t.offsetTop, t = t.offsetParent;
        while (t);
        return n
    }, t.scrollToElementById = function(e, n) {
        var a = t.getElementOffsetById(e);
        void 0 !== a && (location.hash.slice(1) !== e && history.pushState({
            offset: a,
            id: e
        }, "", "#" + e), t.scrollToOffset(a, n))
    }, t.applyToLocalLinks = function(e) {
        void 0 === e && (e = 500);
        var n = document.querySelectorAll('a[href^="#"]');
        [].forEach.call(n, function(n) {
            n.addEventListener("click", function(n) {
                n.preventDefault(), t.scrollToElementById(this.hash.slice(1), e)
            })
        })
    }
}, function(e, t, n) {
    "use strict";
    var a = n(1);
    t.rot13 = function(e) {
        return e.replace(/&lt;/g, "<").replace(/[a-zA-Z]/g, function(e) {
            return String.fromCharCode(("Z" >= e ? 90 : 122) >= (e = e.charCodeAt(0) + 13) ? e : e - 26)
        })
    }, t.restartAnimation = function(e) {
        var t = e.style.display;
        e.style.display = "none", function(e) {
            return e
        }(e.offsetHeight), e.style.display = t
    }, t.detectTouch = function() {
        "ontouchstart"in window ? (document.documentElement.classList.add("touch"), document.addEventListener("touchstart", function() {})) : document.documentElement.classList.add("no-touch")
    }, t.detectHairline = function() {
        var e=!1;
        if (window.devicePixelRatio && devicePixelRatio >= 2) {
            var t = document.createElement("div");
            t.style.border = ".5px solid transparent", document.body.appendChild(t), 1 === t.offsetHeight && (e=!0), document.body.removeChild(t)
        }
        e ? (document.documentElement.classList.remove("no-hairline"), document.documentElement.classList.add("hairline")) : (document.documentElement.classList.remove("hairline"), document.documentElement.classList.add("no-hairline"))
    }, function() {
        var e, n, a, o = function() {
            window.matchMedia("(max-width: 719px)").matches ? (e = "small", n = 18, a = 24) : window.matchMedia("(min-width: 720px) and (max-width: 1519px)").matches ? (e = "medium", n = 18, a = 24) : window.matchMedia("(min-width: 1520px)").matches && (e = "large", n = 24, a = 32)
        };
        o(), addEventListener("load", o), addEventListener("resize", o), t.getLayout = function() {
            return e
        }, t.getFontSize = function() {
            return n
        }, t.getLineHeight = function() {
            return a
        }
    }(), t.disableTransitionsDuringResize = function() {
        var e;
        addEventListener("resize", function() {
            if (e = Date.now(), !document.documentElement.classList.contains("no-transition")) {
                document.documentElement.classList.add("no-transition");
                var n = function() {
                    Date.now() - e < 100 ? setTimeout(n, 100) : (document.documentElement.classList.remove("no-transition"), t.detectHairline())
                };
                setTimeout(n, 100)
            }
        })
    }, t.createBacklinkButton = function(e, t) {
        var n = document.createElement("span");
        n.className = "backlink-button";
        var a = document.createElement("a");
        return a.className = "backlink", a.href = "#" + e, a.title = t, n.appendChild(a), n
    }, t.insertBacklinkButton = function(e) {
        var n = parseInt(e.className.replace(/level/, "")), a = parseInt(document.documentElement.dataset.minBackLinkLevel) || 2, o = parseInt(document.documentElement.dataset.maxBackLinkLevel) || 2, i = document.documentElement.dataset.h2BackLinkTarget || "top";
        if (!(!n || a > n || n > o)) {
            var c, l;
            if (2 >= n)
                c = i, l = "Top";
            else {
                c = e.parentElement.id;
                var s = e.parentElement.getElementsByTagName("h" + (n - 1))[0];
                if (void 0 === s)
                    return;
                l = s.textContent
            }
            var r = t.createBacklinkButton(c, l), d = e.getElementsByTagName("h" + n)[0];
            d.nextSibling ? e.insertBefore(r, d.nextSibling) : e.appendChild(r)
        }
    }, t.addSectionLinks = function() {
        for (var e = parseInt(document.documentElement.dataset.minSectionLinkLevel) || 2, n = parseInt(document.documentElement.dataset.maxSectionLinkLevel) || 4, a = [], o = e; n >= o; o += 1)
            a.push(o);
        a.forEach(function(e) {
            var n = document.getElementsByClassName("level" + e);
            [].forEach.call(n, function(n) {
                var a = n.getElementsByTagName("h" + e)[0];
                if (a) {
                    var o = document.createElement("a");
                    o.className = "section-link";
                    var i = n.id, c = a.textContent;
                    o.href = "#" + i, o.title = c, o.appendChild(a.replaceChild(o, a.firstChild)), t.insertBacklinkButton(n)
                }
            })
        })
    }, t.insertToc = function(e, n, a) {
        if (e) {
            var o = parseInt(e.className.replace(/level/, "")), i = parseInt(document.documentElement.dataset.maxSectionTocLevel) || 2;
            if (o&&!(o > i)) {
                var c = document.createElement("ul");
                c.className = "toc toc" + o + " menu open";
                var l = 0, s = e.getElementsByClassName("level" + (o + 1));
                [].forEach.call(s, function(e) {
                    var n = e.getElementsByTagName("h" + (o + 1))[0];
                    if (n) {
                        var i = document.createElement("li"), s = document.createElement("a");
                        s.href = "#" + e.id, s.title = n.textContent, [].forEach.call(n.childNodes, function(e) {
                            s.appendChild(e.cloneNode(!0))
                        }), i.appendChild(s), c.appendChild(i), l += 1, t.insertToc(e, i, a)
                    }
                }), l && a(e, o, n, c)
            }
        }
    }, t.addSectionToc = function() {
        var e = parseInt(document.documentElement.dataset.minSectionTocLevel) || 1, n = document.querySelectorAll("section.level" + e)[0];
        t.insertToc(n, void 0, function(e, t, n, a) {
            var o = e.getElementsByClassName("level" + (t + 1))[0], i = document.createElement("nav");
            i.appendChild(a), e.classList.add("with-toc"), e.insertBefore(i, o)
        })
    }, t.addMainToc = function() {
        var e = parseInt(document.documentElement.dataset.minSectionTocLevel) || 1, n = document.querySelectorAll("section.level" + e)[0];
        t.insertToc(n, void 0, function(e, t, a, o) {
            if (a) {
                var i = document.createElement("p");
                [].forEach.call(a.childNodes, function(e) {
                    i.appendChild(e)
                }), a.appendChild(i), a.appendChild(o), a.classList.add("with-subtoc")
            } else {
                var c = document.getElementById("main-toc");
                c.appendChild(o), n.classList.add("with-toc")
            }
        })
    }, t.tweakListings = function() {
        var e = new RegExp("(?:\\*\\*)([^\n]*)(?:\\*\\*)", "g"), t = new RegExp("(https?://[^ \n]*?)(?=[ \n]|$|\\.\\.\\.)", "g"), n = new RegExp("(^|\n|~ )([\\$#λ]) ([^\n]*?)(?=\n|$)", "g"), a = document.querySelectorAll("pre:not(.textmate-source):not(.with-tweaks) code");
        [].forEach.call(a, function(a) {
            a.innerHTML = a.innerText.replace(e, "<b>$1</b>").replace(t, '<a href="$1" target="_blank">$1</a>').replace(n, '$1<span class="prompt">$2</span> <span class="input">$3</span>')
        })
    }, t.enableHeaderMenuButton = function() {
        var e = document.getElementById("header-menu-bar"), t = document.getElementById("header-button"), n = document.getElementById("header-menu");
        e && t && n && t.addEventListener("click", function(a) {
            a.preventDefault(), e.classList.toggle("open"), n.classList.toggle("open"), t.classList.toggle("open");
            var o = "true" === localStorage["header-menu-open"];
            o ? localStorage.removeItem("header-menu-open") : localStorage["header-menu-open"] = "true"
        })
    }, t.enableToggleButtons = function() {
        var e = document.getElementsByClassName("toggle-button");
        [].forEach.call(e, function(e) {
            var t = document.getElementById(e.dataset.target);
            e.addEventListener("click", function(n) {
                n.preventDefault(), e.classList.toggle("open"), t.classList.toggle("open");
                var a = "true" === localStorage[e.dataset.target];
                localStorage[e.dataset.target] = a ? "false" : "true"
            }), "true" === localStorage[e.dataset.target] ? (e.classList.add("open"), t.classList.add("open")) : "false" === localStorage[e.dataset.target] && (e.classList.remove("open"), t.classList.remove("open"))
        })
    }, function() {
        t.detectTouch(), t.detectHairline(), t.disableTransitionsDuringResize(), addEventListener("load", function() {
            document.documentElement.classList.contains("add-section-toc") ? t.addSectionToc() : document.documentElement.classList.contains("add-main-toc") && t.addMainToc(), t.addSectionLinks(), document.documentElement.classList.contains("tweak-listings") && t.tweakListings(), t.enableHeaderMenuButton(), t.enableToggleButtons(), a.applyToLocalLinks();
            var e = function() {
                document.documentElement.classList.remove("no-transition")
            };
            setTimeout(e, 100)
        })
    }()
}, function(e, t) {
    "use strict";
    t.ease = function(e) {
        if (0 >= e)
            return 0;
        if (e >= 1)
            return 1;
        var t = 1.0042954579734844, n =- 6.404173895841566, a =- 7.290824133098134;
        return t * Math.exp(n * Math.exp(a * e))
    }
}
]);

