document.addEventListener("DOMContentLoaded", () => {
  const recordInput = document.getElementById("record_input");
  const hiddenInput = document.getElementById("record_hidden");
  
  if (!recordInput || !hiddenInput) return; // 要素がない場合は処理しない
  
  recordInput.addEventListener("input", (event) => {
    const value = event.target.value.trim();
  
    // 正規表現で "1'27"28" のような形式をキャッチ
    const match = value.match(/^(\d*)'*(\d{1,2})"(\d{1,2})$/);
    if (match) {
      const minutes = parseInt(match[1] || "0", 10);
      const seconds = parseInt(match[2], 10);
      const milliseconds = parseInt(match[3], 10);
      const totalMilliseconds = (minutes * 60 + seconds) * 100 + milliseconds;
  
      // hidden input に変換後のデータを入れる
      hiddenInput.value = totalMilliseconds;
    } else {
      // 無効な入力時は hidden フィールドを空にする
      hiddenInput.value = "";
    }
  });
});
  