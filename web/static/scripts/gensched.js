// Javascript for password reset interactive page and pop-up

// eslint-disable no-unused-vars
function toggleInput() {
  const selector = document.getElementById("option_selector").value;
  const individual = document.getElementById("individual");
  const collective = document.getElementById("collective");

  if (selector === "individual") {
    individual.style.display = "block";
    collective.style.display = "none";
  } else if (selector === "collective") {
    individual.style.display = "none";
    collective.style.display = "block";
  } else {
    individual.style.display = "none";
    collective.style.display = "none";
  }
  console.log(selector);
}

/* eslint-disable no-unused-vars */
function confirmSubmission() {
  document.getElementById("reset-form").submit();
  document.getElementById("confirm-dialog").style.display = "none";
}

/* eslint-disable no-unused-vars */
function cancelOperation() {
  document.getElementById("confirm-dialog").close();
  document.getElementById("staff_id").value = "";
  document.getElementById("option_selector").value = "";
  document.getElementById("confirm-dialog").style.display = "none";
  document.getElementById("individual").style.display = "none";
  document.getElementById("collective").style.display = "none";
}

document.addEventListener("DOMContentLoaded", function () {
  var checkbox = document.getElementById("createall");
  var submitButton = document.getElementById("btnsubmit");

  checkbox.addEventListener("change", function () {
    submitButton.disabled = !checkbox.checked;
  });
});

document.addEventListener("DOMContentLoaded", function () {
  var checkbox = document.getElementById("createone");
  var submitButton = document.getElementById("btnsubmit");

  checkbox.addEventListener("change", function () {
    submitButton.disabled = !checkbox.checked;
  });
});
