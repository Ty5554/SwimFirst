document.addEventListener("DOMContentLoaded", () => {
  const recordInput = document.getElementById("record_input");
  const hiddenInput = document.getElementById("record_hidden");
  const form = document.querySelector("form");

  if (!recordInput || !hiddenInput || !form) return;

  const updateHiddenInput = () => {
    const value = recordInput.value.trim();
    const match = value.match(/^(\d*)'*(\d{1,2})"(\d{1,2})$/);
    if (match) {
      const minutes = parseInt(match[1] || "0", 10);
      const seconds = parseInt(match[2], 10);
      const milliseconds = parseInt(match[3], 10);
      const totalMilliseconds = (minutes * 60 + seconds) * 100 + milliseconds;
      hiddenInput.value = totalMilliseconds;
    } else {
      hiddenInput.value = "";
    }
  };

  // スマホ対策: `input`, `change`, `blur` の全てで発火させる
  recordInput.addEventListener("input", updateHiddenInput);
  recordInput.addEventListener("change", updateHiddenInput);
  recordInput.addEventListener("blur", updateHiddenInput);

  // フォーム送信時に hiddenInput の値を確実にセット
  form.addEventListener("submit", () => {
    updateHiddenInput();
  });
});
