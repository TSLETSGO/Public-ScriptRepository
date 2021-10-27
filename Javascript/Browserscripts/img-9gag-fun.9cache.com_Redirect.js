// ==UserScript==
// @name        img-9gag-fun.9cache.com Redirect
// @description Redirect img-9gag-fun.9cache.com/photo to 9gag.com/gag as workaround for videos not playing
// @namespace   customized version
// @match       https://img-9gag-fun.9cache.com/photo*
// @run-at      document-start
// @grant       none
// @version     1.0
// @author      TSLETSGO
// ==/UserScript==

// 9gag url
ninegagURL = "https://9gag.com/";

// current location
url = new URL(window.location);

if (url.href.startsWith("https://img-9gag-fun.9cache.com/photo")) {
  // extract videoid from https://img-9gag-fun.9cache.com/photo
  firstfragment_video = url.pathname.split("photo/")[1];
  videoid = firstfragment_video.split("_")[0];
}

// Put the new URL together
redirectURL = new URL(ninegagURL.toString())
redirectURL.pathname = "/gag/" + videoid;

//go to 9gag video
window.location = redirectURL.toString();