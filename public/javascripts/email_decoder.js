function decodeLink() {
  anchor = $(this)
  var href = anchor.attr("href");
  var address = href.replace(/.*contactto\/new\/([a-z0-9._%$-]+)\^([a-z0-9._%$-]+)/i, '$1' + '@' + '$2').replace(/\$/g, '.');

  if (href != address) {
    anchor.attr('href', 'mailto:' + decode(address));
  }

  if (anchor.text().match(/^(email this contact|click here)$/i)) {
    anchor.html(decode(address))
  }
}

function decode(encoded) {
  return encoded.replace(/[a-zA-Z]/g, function(c){
      return String.fromCharCode((c <= "Z" ? 90 : 122) >= (c = c.charCodeAt(0) + 13) ? c : c - 26);
  });
}
