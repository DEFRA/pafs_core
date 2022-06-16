window.onload = function () {
  if (document.getElementById("natural_flood_risk_measures_step_other_flood_measures_selected").checked == false) {
    document.getElementById("other-flood-measures").style.visibility = "hidden";
  }
};

function toggleBoxVisibility() {
  if (document.getElementById("natural_flood_risk_measures_step_other_flood_measures_selected").checked == true) {
    document.getElementById("other-flood-measures").style.visibility = "visible";
  }
  else {
    document.getElementById("other-flood-measures").style.visibility = "hidden";
  }
}
