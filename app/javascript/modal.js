document.addEventListener("DOMContentLoaded", function () {
  setTimeout(() => { // 100ms 遅延させる
    const modal = document.createElement("div");
    modal.id = "imageModal";
    modal.className = "fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center hidden z-50";
    modal.style.display = "none"; // 初期状態で非表示にする
    modal.innerHTML = `
      <div class="relative">
        <span id="closeModal" class="absolute top-2 right-2 text-white text-3xl cursor-pointer">&times;</span>
        <img id="modalImage" class="max-w-full max-h-screen" src="" alt="拡大画像">
      </div>
    `;
    document.body.appendChild(modal);

    const popupImages = document.querySelectorAll(".popup-image");
    const modalImage = document.getElementById("modalImage");
    const closeModal = document.getElementById("closeModal");

    popupImages.forEach(image => {
      image.addEventListener("click", function () {
        modalImage.src = this.src;
        modal.style.display = "flex"; // モーダル表示
        modal.classList.remove("hidden");
      });
    });

    closeModal.addEventListener("click", function () {
      modal.style.display = "none"; // モーダル非表示
      modal.classList.add("hidden");
    });

    modal.addEventListener("click", function (event) {
      if (event.target === modal) {
        modal.style.display = "none";
        modal.classList.add("hidden");
      }
    });

  }, 300); // 300ms 遅延
});
