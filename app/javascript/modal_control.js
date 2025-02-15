document.addEventListener("DOMContentLoaded", function() {
  const csrfToken = document.querySelector("meta[name='csrf-token']")?.content;

  if (window.showModal && window.modalType) {
    Alpine.store(window.modalType, true);
    
    console.log("モーダルを開きます:", window.modalType);

    fetch("/hide_modal", {
      method: "POST",
      headers: {
        "X-CSRF-Token": csrfToken,
        "Content-Type": "application/json"
      }
    })
    .then(response => {
      if (!response.ok) {
        console.error("fetch('/hide_modal') に失敗:", response.status);
      } else {
        console.log("fetch('/hide_modal') が成功しました");
      }
    })
    .catch(error => {
      console.error("fetch('/hide_modal') 実行時のエラー:", error);
    });
  }
});
