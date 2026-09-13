const state = { goal: null, mainPlan: null };
const ui = {
  form: document.querySelector('#journeyForm'),
  goalText: document.querySelector('#goalText'),
  nowTime: document.querySelector('#nowTime'),
  planButton: document.querySelector('#planButton'),
  statusButton: document.querySelector('#statusButton'),
  replanButton: document.querySelector('#replanButton'),
  healthText: document.querySelector('#healthText'),
  health: document.querySelector('.health'),
  stage: document.querySelector('#stageChip'),
  message: document.querySelector('#statusMessage'),
  summary: document.querySelector('#summary'),
  response: document.querySelector('#responseBody'),
  latency: document.querySelector('#latency'),
  title: document.querySelector('#observerTitle'),
};

function setStage(text, style = '') {
  ui.stage.textContent = text;
  ui.stage.className = `chip ${style}`;
}

function setMessage(text, style = '') {
  ui.message.textContent = text;
  ui.message.className = `status-message ${style}`;
}

function setBusy(button, busy, label) {
  button.disabled = busy;
  button.dataset.label ||= button.textContent;
  button.textContent = busy ? label : button.dataset.label;
}

function showResponse(title, payload, elapsed) {
  ui.title.textContent = title;
  ui.response.textContent = JSON.stringify(payload, null, 2);
  ui.latency.textContent = `${elapsed} ms`;
}

async function request(path, body) {
  const started = performance.now();
  const response = await fetch(path, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
  const elapsed = Math.round(performance.now() - started);
  let payload;
  try { payload = await response.json(); } catch { throw new Error(`接口返回了非 JSON 内容（HTTP ${response.status}）`); }
  if (!response.ok || !payload.success) throw new Error(payload.message || `请求失败（HTTP ${response.status}）`);
  return { payload, elapsed };
}

function renderPlan(data) {
  const plan = data.mainPlan;
  const risks = data.riskTips?.length ? data.riskTips.map(item => `<li class="risk">${escapeHtml(item)}</li>`).join('') : '<li>当前未发现额外风险提示。</li>';
  ui.summary.className = 'summary';
  ui.summary.innerHTML = `
    <h3>${escapeHtml(plan.type)} · ${escapeHtml(plan.eta)} 抵达</h3>
    <div class="metrics">
      <div class="metric"><b>${escapeHtml(String(plan.cost))}</b><span>预计费用（元）</span></div>
      <div class="metric"><b>${escapeHtml(String(plan.durationMinutes))}</b><span>预计耗时（分钟）</span></div>
      <div class="metric"><b>${escapeHtml(plan.riskLevel)}</b><span>准时风险</span></div>
    </div>
    <p>${escapeHtml(plan.reason)}</p>
    <ul>${risks}</ul>`;
}

function renderStatus(data) {
  ui.summary.className = 'summary';
  ui.summary.innerHTML = `<h3>${escapeHtml(data.currentState)}</h3><p>${escapeHtml(data.nextAction)}</p><ul><li class="${data.needReplan ? 'risk' : ''}">${data.needReplan ? `建议重规划：${escapeHtml(data.reason)}` : '当前方案仍可执行。'}</li></ul>`;
}

function renderReplan(data) {
  const plan = data.newPlan;
  ui.summary.className = 'summary';
  ui.summary.innerHTML = `<h3>建议切换至 ${escapeHtml(plan.type)}</h3><div class="metrics"><div class="metric"><b>${escapeHtml(plan.eta)}</b><span>新预计抵达</span></div><div class="metric"><b>+${escapeHtml(String(data.extraCost))}</b><span>费用变化（元）</span></div><div class="metric"><b>${escapeHtml(data.riskLevel)}</b><span>新风险等级</span></div></div><p>${escapeHtml(data.explanation)}</p><ul><li class="risk">触发原因：${escapeHtml(data.trigger)}</li><li>${escapeHtml(data.action)}</li></ul>`;
}

function escapeHtml(value) {
  return String(value).replace(/[&<>'"]/g, char => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', "'": '&#39;', '"': '&quot;' }[char]));
}

async function createPlan(event) {
  event.preventDefault();
  const text = ui.goalText.value.trim();
  if (!text) { setMessage('请输入一句话出行目标后再提交。', 'error'); ui.goalText.focus(); return; }
  setBusy(ui.planButton, true, '正在解析与规划…');
  setStage('正在请求', 'busy');
  try {
    const parsed = await request('/api/parse-goal', { text });
    const goal = parsed.payload.data.goal;
    if (parsed.payload.data.missingFields.length) {
      showResponse('目标字段待补充', parsed.payload, parsed.elapsed);
      setMessage(`还缺少：${parsed.payload.data.missingFields.join('、')}。请补充后重试。`, 'error');
      setStage('字段不完整', 'error');
      return;
    }
    state.goal = goal;
    const planned = await request('/api/plan-route', { goal });
    state.mainPlan = planned.payload.data.mainPlan;
    showResponse('主方案与 Plan B', planned.payload, parsed.elapsed + planned.elapsed);
    renderPlan(planned.payload.data);
    setMessage('已完成目标解析与路线生成。现在可检查行程状态或模拟暴雨重规划。', 'success');
    setStage('方案已就绪', 'ready');
    ui.statusButton.disabled = false;
    ui.replanButton.disabled = false;
  } catch (error) {
    setMessage(`请求失败：${error.message}`, 'error');
    setStage('请求失败', 'error');
  } finally { setBusy(ui.planButton, false); }
}

async function checkStatus() {
  if (!state.goal || !state.mainPlan) return;
  setBusy(ui.statusButton, true, '正在验证…');
  setStage('正在更新状态', 'busy');
  try {
    const result = await request('/api/update-status', { goal: state.goal, plan: state.mainPlan, now: ui.nowTime.value || '16:30' });
    showResponse('当前行程状态', result.payload, result.elapsed);
    renderStatus(result.payload.data);
    setMessage('状态机响应正常。可继续模拟天气变化。', 'success');
    setStage('状态已验证', 'ready');
  } catch (error) { setMessage(`状态验证失败：${error.message}`, 'error'); setStage('请求失败', 'error'); }
  finally { setBusy(ui.statusButton, false); }
}

async function simulateRain() {
  if (!state.goal || !state.mainPlan) return;
  setBusy(ui.replanButton, true, '正在重规划…');
  setStage('正在重规划', 'busy');
  try {
    const result = await request('/api/replan', { goal: state.goal, currentPlan: state.mainPlan, context: { now: ui.nowTime.value || '16:30', weather: { city: state.goal.destination, weather: '暴雨', warning: '调试场景' } } });
    showResponse('暴雨重规划结果', result.payload, result.elapsed);
    if (result.payload.data) { renderReplan(result.payload.data); setMessage('已用暴雨上下文验证重规划接口。', 'success'); setStage('重规划完成', 'ready'); }
    else { setMessage('该方案在当前条件下无需重规划。可修改目标后重试。', 'error'); setStage('未触发重规划', 'error'); }
  } catch (error) { setMessage(`重规划失败：${error.message}`, 'error'); setStage('请求失败', 'error'); }
  finally { setBusy(ui.replanButton, false); }
}

async function checkHealth() {
  try {
    const response = await fetch('/api/health');
    const payload = await response.json();
    if (!response.ok || !payload.success) throw new Error('健康检查未通过');
    ui.healthText.textContent = '服务在线 · :8000';
    ui.health.className = 'health ok';
    setMessage('服务在线。可以直接创建测试行程。', 'success');
  } catch {
    ui.healthText.textContent = '服务不可达';
    ui.health.className = 'health fail';
    setMessage('无法连接后端。请确认 FastAPI 已在 8000 端口启动。', 'error');
  }
}

ui.form.addEventListener('submit', createPlan);
ui.statusButton.addEventListener('click', checkStatus);
ui.replanButton.addEventListener('click', simulateRain);
checkHealth();
