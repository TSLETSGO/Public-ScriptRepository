// ==UserScript==
// @name        Invidious Redirect
// @description Simple script to redirect YouTube to an Invidious instance
// @namespace   customized version
// @match       *://youtube.com/*
// @match       *://*.youtube.com/*
// @match       *://youtu.be/*
// @run-at      document-start
// @grant       none
// @version     1.0
// @author      TSLETSGO
// ==/UserScript==

/* CONFIG */
// invidious instance - change as desired
var invidiousinstance = "yewtu.be"

// check window location
var url = new URL(window.location);

// extract correct info for redirect if on consent.*
if (url.href.startsWith("https://consent.")) {
  // retrieve continue URL
  var redirectURL = url.searchParams.get("continue");
  var hosturl = redirectURL.split("/")[2];
}
else {
  var redirectURL = url.href;
  var hosturl = url.host;
}

// replace hosturl with invidiousinstance
redirectURL = redirectURL.replace(hosturl, invidiousinstance)

// go to the new redirectURL
window.location = redirectURL.toString();