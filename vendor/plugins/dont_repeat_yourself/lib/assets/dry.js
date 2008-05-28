// Lifted from Ruby RDoc
function toggleSource( id ) {
  var elem
  var link

  if( document.getElementById )
  {
    elem = document.getElementById( id )
    link = document.getElementById( "l_" + id )
  }
  else if ( document.all )
  {
    elem = eval( "document.all." + id )
    link = eval( "document.all.l_" + id )
  }
  else
    return false;

  if( elem.style.display == "block" )
  {
    elem.style.display = "none"
    link.innerHTML = "Show duplicate lines source code"
  }
  else
  {
    elem.style.display = "block"
    link.innerHTML = "Hide duplicate lines source code"
  }
}
