function getName() {
  const params = new URLSearchParams(window.location.search);
  const raw = params.get("name") || "Jackie";
  const first = raw.trim().split(/\s+/)[0];
  return first || "Jackie";
}

function setNameAnywhere() {
  const name = getName();
  document.querySelectorAll("[data-name]").forEach(el => {
    el.textContent = name;
  });
}

function setupNoButton() {
  const noBtn = document.getElementById("noBtn");
  const stage = document.getElementById("stage");
  if (!noBtn || !stage) return;

  let tries = 0;

  // 🔥 TUNE THESE IF YOU WANT
  const TRIGGER_DISTANCE = 70;     // must get closer (55–85 ideal)
  const COOLDOWN_MS = 600;         // time between dodges
  const SAFE_DISTANCE = 130;       // how far it jumps away

  let lastDodge = 0;

  // smooth animation
  noBtn.style.position = "absolute";
  noBtn.style.transition = "left 0.35s ease, top 0.35s ease";

  // starting position
  noBtn.style.left = "50%";
  noBtn.style.top = "150px";
  noBtn.style.transform = "translateX(-50%)";

  function randomSpot(avoidClientX, avoidClientY) {
    const pad = 10;
    const s = stage.getBoundingClientRect();
    const b = noBtn.getBoundingClientRect();

    const maxX = Math.max(pad, s.width - b.width - pad);
    const maxY = Math.max(pad, s.height - b.height - pad);

    const relX = avoidClientX - s.left;
    const relY = avoidClientY - s.top;

    for (let i = 0; i < 20; i++) {
      const x = pad + Math.random() * (maxX - pad);
      const y = pad + Math.random() * (maxY - pad);

      const dx = x - relX;
      const dy = y - relY;
      const dist = Math.sqrt(dx * dx + dy * dy);

      if (dist > SAFE_DISTANCE) return { x, y };
    }

    return {
      x: pad + Math.random() * (maxX - pad),
      y: pad + Math.random() * (maxY - pad)
    };
  }

  function setMessage() {
    const msg = document.getElementById("tryMsg");
    if (!msg) return;

    const name = getName();
    const lines = [
      "nice try 😭",
      "not happening",
      "be serious",
      `${name}… come on 😂`,
      "okay you’re persistent lol",
      ":/",
      "alright now you're stressing me",
      "you must not love me",
      "what if I was a wormy",
      "i see you've made your choice :("
    ];

    msg.textContent = lines[Math.min(tries - 1, lines.length - 1)];
  }

  function dodge(clientX, clientY) {
    const now = Date.now();

    if (now - lastDodge < COOLDOWN_MS) return;
    lastDodge = now;

    tries++;

    const { x, y } = randomSpot(clientX, clientY);
    noBtn.style.left = `${x}px`;
    noBtn.style.top = `${y}px`;
    noBtn.style.transform = "translateX(0)";

    setMessage();

    if (navigator.vibrate) navigator.vibrate(20);
  }

  // 🖥 Desktop — trigger only when VERY close
  stage.addEventListener("mousemove", (e) => {
    const r = noBtn.getBoundingClientRect();
    const cx = r.left + r.width / 2;
    const cy = r.top + r.height / 2;

    const dx = e.clientX - cx;
    const dy = e.clientY - cy;
    const dist = Math.sqrt(dx * dx + dy * dy);

    if (dist < TRIGGER_DISTANCE) {
      dodge(e.clientX, e.clientY);
    }
  });

  // Backup triggers
  noBtn.addEventListener("mouseenter", (e) => {
    dodge(e.clientX, e.clientY);
  });

  noBtn.addEventListener("click", (e) => {
    e.preventDefault();
    dodge(e.clientX, e.clientY);
  });

  // 📱 Mobile support
  noBtn.addEventListener("touchstart", (e) => {
    e.preventDefault();
    const t = e.touches[0];
    dodge(t.clientX, t.clientY);
  }, { passive: false });
}

document.addEventListener("DOMContentLoaded", () => {
  setNameAnywhere();
  setupNoButton();
});
