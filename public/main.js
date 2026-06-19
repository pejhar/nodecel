const BASE_URL = "http://192.168.43.1:8000"; // IP گوشی خودت

function checkServer() {
  document.getElementById("status").innerText = "Checking...";

  fetch(BASE_URL)
    .then(() => {
      document.getElementById("status").innerText = "Server is UP";
    })
    .catch(() => {
      document.getElementById("status").innerText = "Server is DOWN";
    });
}

function openApp() {
  window.location.href = BASE_URL;
}

function openAPI() {
  window.location.href = BASE_URL + "/api";
}