document.addEventListener("DOMContentLoaded", function() {
  const csrfToken = document.querySelector("meta[name='csrf-token']")?.content;

  if (window.showModal && window.modalType) {
    setTimeout(() => { // 遷移後の処理を遅延させる
      Alpine.store(window.modalType, true);
      console.log("モーダルを開きます:", window.modalType);
    }, 100); // 100ms の遅延を入れる

    fetch("/hide_modal", {
      method: "POST",
      headers: {
        "X-CSRF-Token": csrfToken,
        "Content-Type": "application/json"
      }
    }).then(response => {
      if (!response.ok) {
        console.error("fetch('/hide_modal') に失敗:", response.status);
      } else {
        console.log("fetch('/hide_modal') が成功しました");
      }
    }).catch(error => {
      console.error("fetch('/hide_modal') 実行時のエラー:", error);
    });
  }
});
