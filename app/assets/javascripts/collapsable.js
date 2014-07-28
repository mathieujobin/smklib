function debug(str) {}

function correct_value(cond) {
    if (cond) {
    if ('" . PMA_USR_BROWSER_AGENT . "' == 'IE') {
      return 'block';
    } else {
      return 'table-row-group';
    }
  } else return 'none';
}

function show_details(row) {
  row.className = row.className.replace (' over', '') + ' over';
}

function hide_last_shown(row) {
  row.className = row.className.replace (' over', '');
}

var smooth_timer;
function smoothHeight(id, curH, targetH, stepH, mode) {
  //alert(id + ' == ' + mode);
  diff = targetH - curH;
  if (diff != 0) {
    newH = (diff > 0) ? curH + stepH : curH - stepH;
    document.getElementById(id).style.height = newH + "px";
    if (smooth_timer) window.clearTimeout(smooth_timer);
    smooth_timer = window.setTimeout( "smoothHeight('" + id + "'," + newH + "," + targetH + "," + stepH + ",'" + mode + "')", 20 );
  }
  else if (mode != "o") document.getElementById(mode).style.display="none";
}

function proceed_on_click(row, speed) {
  trRow = document.getElementById(row.id + "_details");
  divBlock = document.getElementById(row.id + "_block_details");
  if (trRow != null) {
    if (trRow.style.display=="none") {
      trRow.style.display="";
      divBlock.blabla = divBlock.scrollHeight // try to store the first height to then use the same one from the begining.
      debug("Show Details, offsetHeight: " + divBlock.offsetHeight + " scrollHeight: " + divBlock.scrollHeight + " saved: " + divBlock.bla);
      if (speed == 0) { speed = divBlock.scrollHeight }
      h = Math.ceil(divBlock.scrollHeight/speed)*speed
      smoothHeight(row.id + "_block_details", 0, h, speed, 'o');
      row.className = row.className.replace (' clicked', '') + ' clicked';
    }
    else {
      debug("Hide Details, offsetHeight: " + divBlock.offsetHeight + " scrollHeight: " + divBlock.scrollHeight);
      if (speed == 0) { speed = divBlock.scrollHeight }
      h = Math.ceil(divBlock.scrollHeight/speed)*speed
      smoothHeight(row.id + "_block_details", h, 0, speed, row.id + "_details");
      row.className = row.className.replace (' clicked', '');
    }
  }
  debug('');
}