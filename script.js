const canvas = document.getElementById("game");
const ctx = canvas.getContext("2d");
const scoreEl = document.getElementById("score");
const waveEl = document.getElementById("wave");
const overlay = document.getElementById("overlay");
const titleEl = document.getElementById("title");
const messageEl = document.getElementById("message");
const startButton = document.getElementById("start");

const state = {
  running: false,
  paused: false,
  score: 0,
  wave: 1,
  time: 0,
  player: {
    x: canvas.width / 2,
    y: canvas.height / 2,
    size: 18,
    speed: 3.4,
  },
  enemies: [],
  orbs: [],
  keys: new Set(),
};

const randomBetween = (min, max) => Math.random() * (max - min) + min;

const spawnEnemy = () => {
  const edge = Math.floor(Math.random() * 4);
  const size = randomBetween(12, 28);
  let x = 0;
  let y = 0;
  if (edge === 0) {
    x = randomBetween(0, canvas.width);
    y = -size;
  } else if (edge === 1) {
    x = canvas.width + size;
    y = randomBetween(0, canvas.height);
  } else if (edge === 2) {
    x = randomBetween(0, canvas.width);
    y = canvas.height + size;
  } else {
    x = -size;
    y = randomBetween(0, canvas.height);
  }
  return {
    x,
    y,
    size,
    speed: randomBetween(0.7, 1.6) + state.wave * 0.12,
  };
};

const spawnOrb = () => ({
  x: randomBetween(30, canvas.width - 30),
  y: randomBetween(30, canvas.height - 30),
  size: 10,
  pulse: randomBetween(0, Math.PI * 2),
});

const resetGame = () => {
  state.score = 0;
  state.wave = 1;
  state.time = 0;
  state.player.x = canvas.width / 2;
  state.player.y = canvas.height / 2;
  state.enemies = Array.from({ length: 6 }, spawnEnemy);
  state.orbs = Array.from({ length: 3 }, spawnOrb);
  updateHud();
};

const updateHud = () => {
  scoreEl.textContent = state.score.toString();
  waveEl.textContent = state.wave.toString();
};

const setOverlay = (visible, title, message, buttonText) => {
  overlay.classList.toggle("hidden", !visible);
  titleEl.textContent = title;
  messageEl.textContent = message;
  startButton.textContent = buttonText;
};

const startGame = () => {
  resetGame();
  state.running = true;
  state.paused = false;
  setOverlay(false);
};

const endGame = () => {
  state.running = false;
  setOverlay(
    true,
    "Квадраты догнали",
    `Счёт ${state.score}. Нажмите старт, чтобы начать снова.`,
    "Заново"
  );
};

const togglePause = () => {
  if (!state.running) return;
  state.paused = !state.paused;
  if (state.paused) {
    setOverlay(true, "Пауза", "Нажмите старт, чтобы продолжить.", "Продолжить");
  } else {
    setOverlay(false);
  }
};

const movePlayer = () => {
  let dx = 0;
  let dy = 0;
  if (state.keys.has("ArrowUp") || state.keys.has("KeyW")) dy -= 1;
  if (state.keys.has("ArrowDown") || state.keys.has("KeyS")) dy += 1;
  if (state.keys.has("ArrowLeft") || state.keys.has("KeyA")) dx -= 1;
  if (state.keys.has("ArrowRight") || state.keys.has("KeyD")) dx += 1;

  const length = Math.hypot(dx, dy) || 1;
  const stepX = (dx / length) * state.player.speed;
  const stepY = (dy / length) * state.player.speed;

  state.player.x = Math.max(
    state.player.size,
    Math.min(canvas.width - state.player.size, state.player.x + stepX)
  );
  state.player.y = Math.max(
    state.player.size,
    Math.min(canvas.height - state.player.size, state.player.y + stepY)
  );
};

const updateEnemies = () => {
  state.enemies.forEach((enemy) => {
    const dx = state.player.x - enemy.x;
    const dy = state.player.y - enemy.y;
    const distance = Math.hypot(dx, dy) || 1;
    enemy.x += (dx / distance) * enemy.speed;
    enemy.y += (dy / distance) * enemy.speed;
  });
};

const updateOrbs = () => {
  state.orbs.forEach((orb) => {
    orb.pulse += 0.06;
  });
};

const checkCollisions = () => {
  const player = state.player;
  for (const enemy of state.enemies) {
    const dist = Math.hypot(player.x - enemy.x, player.y - enemy.y);
    if (dist < player.size + enemy.size * 0.7) {
      endGame();
      return;
    }
  }

  state.orbs = state.orbs.filter((orb) => {
    const dist = Math.hypot(player.x - orb.x, player.y - orb.y);
    if (dist < player.size + orb.size) {
      state.score += 5;
      return false;
    }
    return true;
  });

  if (state.orbs.length < 3) {
    state.orbs.push(spawnOrb());
  }
};

const maybeAdvanceWave = () => {
  state.time += 1;
  if (state.time % 600 === 0) {
    state.wave += 1;
    state.enemies.push(spawnEnemy());
    state.score += 10;
  }
};

const drawBackground = () => {
  ctx.fillStyle = "rgba(6, 8, 18, 0.9)";
  ctx.fillRect(0, 0, canvas.width, canvas.height);

  ctx.strokeStyle = "rgba(255, 255, 255, 0.05)";
  for (let i = 0; i < canvas.width; i += 60) {
    ctx.beginPath();
    ctx.moveTo(i, 0);
    ctx.lineTo(i, canvas.height);
    ctx.stroke();
  }
  for (let i = 0; i < canvas.height; i += 60) {
    ctx.beginPath();
    ctx.moveTo(0, i);
    ctx.lineTo(canvas.width, i);
    ctx.stroke();
  }
};

const drawPlayer = () => {
  ctx.fillStyle = "#35d0ba";
  ctx.shadowColor = "rgba(53, 208, 186, 0.65)";
  ctx.shadowBlur = 12;
  ctx.fillRect(
    state.player.x - state.player.size,
    state.player.y - state.player.size,
    state.player.size * 2,
    state.player.size * 2
  );
  ctx.shadowBlur = 0;
};

const drawEnemies = () => {
  ctx.fillStyle = "#f2f2f2";
  ctx.shadowColor = "rgba(255, 255, 255, 0.4)";
  ctx.shadowBlur = 6;
  state.enemies.forEach((enemy) => {
    ctx.fillRect(enemy.x - enemy.size, enemy.y - enemy.size, enemy.size * 2, enemy.size * 2);
  });
  ctx.shadowBlur = 0;
};

const drawOrbs = () => {
  state.orbs.forEach((orb) => {
    const pulse = (Math.sin(orb.pulse) + 1) / 2;
    const size = orb.size + pulse * 6;
    ctx.fillStyle = "rgba(95, 140, 255, 0.85)";
    ctx.beginPath();
    ctx.arc(orb.x, orb.y, size, 0, Math.PI * 2);
    ctx.fill();
  });
};

const drawHud = () => {
  ctx.fillStyle = "rgba(255, 255, 255, 0.12)";
  ctx.fillRect(12, 12, 160, 54);
  ctx.fillStyle = "#fff";
  ctx.font = "16px sans-serif";
  ctx.fillText(`Счёт: ${state.score}`, 24, 36);
  ctx.fillText(`Волна: ${state.wave}`, 24, 56);
};

const loop = () => {
  if (state.running && !state.paused) {
    movePlayer();
    updateEnemies();
    updateOrbs();
    checkCollisions();
    maybeAdvanceWave();
    updateHud();
  }

  drawBackground();
  drawOrbs();
  drawEnemies();
  drawPlayer();
  drawHud();

  requestAnimationFrame(loop);
};

startButton.addEventListener("click", () => {
  if (!state.running) {
    startGame();
    return;
  }
  if (state.paused) {
    state.paused = false;
    setOverlay(false);
  }
});

window.addEventListener("keydown", (event) => {
  if (event.code === "Space") {
    event.preventDefault();
    togglePause();
    return;
  }
  if (event.code === "KeyR") {
    event.preventDefault();
    startGame();
    return;
  }
  state.keys.add(event.code);
});

window.addEventListener("keyup", (event) => {
  state.keys.delete(event.code);
});

setOverlay(true, "Готовы?", "Используйте WASD или стрелки, чтобы выжить.", "Старт");
loop();
