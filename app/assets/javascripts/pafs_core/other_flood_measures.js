window.onload = function () {
  const otherMeasures = document.getElementById('natural_flood_risk_measures_step_other_flood_measures_selected');
  if (otherMeasures !== null && otherMeasures.checked === false) {
    document.getElementById("other-flood-measures").style.visibility = "hidden";
  }
};

function toggleBoxVisibility() {
  const otherMeasures = document.getElementById("natural_flood_risk_measures_step_other_flood_measures_selected");
  if (otherMeasures !== null && otherMeasures.checked === true) {
    document.getElementById("other-flood-measures").style.visibility = "visible";
  }
  else {
    document.getElementById("other-flood-measures").style.visibility = "hidden";
  }
}
