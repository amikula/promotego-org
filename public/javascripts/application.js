// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
//Event.addBehavior({
//  "a.obfuscated": EmailDecoder
//});
$(document).ready(function() {
  $("a.obfuscated").each(decodeLink)
});
