window.onload = function () {
  const other_measures = document.getElementById("natural_flood_risk_measures_step_other_flood_measures_selected");
  if (other_measures != null && other_measures.checked == false) {
    document.getElementById("other-flood-measures").style.visibility = "hidden";
  }
};

function toggleBoxVisibility() {
  const other_measures = document.getElementById("natural_flood_risk_measures_step_other_flood_measures_selected");
  if (other_measures != null && other_measures.checked == true) {
    document.getElementById("other-flood-measures").style.visibility = "visible";
  }
  else {
    document.getElementById("other-flood-measures").style.visibility = "hidden";
  }
}
