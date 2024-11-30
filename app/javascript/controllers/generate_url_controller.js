import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["urlContainer", "link"];

  // URLを生成する
  async generate() {
    try {
      // サーバーにリクエストを送信
      const response = await fetch("/team_invitations/generate_url", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').getAttribute("content"),
        },
      });

      if (!response.ok) {
        throw new Error(`リクエストエラー: ${response.statusText}`);
      }

      // レスポンスデータを取得
      const data = await response.json();

      // URLをリンクに表示
      this.linkTarget.textContent = data.url;
      this.linkTarget.href = data.url;

      // URL表示エリアを表示
      this.urlContainerTarget.classList.remove("hidden");
    } catch (error) {
      console.error("エラーが発生しました:", error);
      alert("URLの生成に失敗しました。");
    }
  }
}
