function AddToCategoryClick(id, me) {
   obj = document.getElementById(id);
   obj.value = me.value;
}
function showdiv(element_name, display_value) {
   if (document.getElementById) { // DOM3 = IE5, NS6
      document.getElementById(element_name).style.display = display_value;
   } else {
      if (document.layers) { // Netscape 4
         document.hideshow.display = display_value;
      } else { // IE 4
         document.all.hideshow.style.display = display_value;
      }
   }
}
function showOrHide(element_name) {
   if (document.getElementById) { // DOM3 = IE5, NS6
      if (document.getElementById(element_name).style.display != 'none'){
         showdiv(element_name, 'none');
      }else{
         showdiv(element_name, 'inline');
      }
   } else {
      if (document.layers) { // Netscape 4
         if (document.hideshow.display != 'none'){
            showdiv(element_name, 'none');
         } else {
            showdiv(element_name, 'inline');
         }
      } else { // IE 4
         if (document.all.hideshow.style.display != 'none'){
            showdiv(element_name, 'none');
         }else{
            showdiv(element_name, 'inline');
         }
      }
   }
}

