# LoanLens — presentation runbook (viva / demo)

## 5 minutes before you present

1. Plug in laptop power; disable sleep on AC power.
2. Close heavy apps (optional: extra browsers, games).
3. In PowerShell:

```powershell
cd "C:\Users\karak\OneDrive\Desktop\LoanLens"
.\scripts\verify_before_demo.ps1
.\scripts\start_loanlens.ps1
```

4. Browser should open **http://127.0.0.1:8000** — if not, open it manually.
5. **Leave the PowerShell window open** (closing it stops the server).

### Manual start (if scripts are blocked)

```powershell
cd "C:\Users\karak\OneDrive\Desktop\LoanLens"
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
.\.venv\Scripts\Activate.ps1
python -m src.download_data
python -m web
```

Then open **http://127.0.0.1:8000**.

---

## Suggested 12–15 minute presentation flow

| Time | What to say / show |
|------|---------------------|
| 1 min | **Problem:** Banks screen housing loans using many fields; goal is *decision support*, not auto-lending. Binary classification on historical `Loan_Status`. |
| 1 min | **Data:** Dream Housing Finance — 614 applications, SHA-256 verified (`data/raw/source.json`). Train/holdout 491/123, stratified. |
| 2 min | **Pipeline:** Show **Methodology** page or `docs/03_preprocessing.md` — split first, then impute/scale/encode; no leakage. |
| 2 min | **Model:** Decision Tree selected by 5-fold CV (5 algorithms). Holdout @ 0.50: **~88.6% accuracy, F1 ~0.92, ROC-AUC ~0.84**. Show **Workspace → evidence** charts. |
| 4 min | **Live demo (main part):** **Assessment** → **Load real example** → Run → show probability, Approved/Rejected, **SHAP waterfall** and three reasons. Mention standard threshold **0.50**. |
| 2 min | **Batch:** **Batch** → upload `data/demo/presentation_batch.csv` → show summary + download results. |
| 1 min | **Limitations (important for marks):** Historical approvals only — not default/NPA prediction; cost policy **0.76** fails on final tree (show in policy dropdown if asked). |
| 1 min | **Future work:** Larger permissioned data, repayment labels, external validation, fairness review before production. |

### Strong viva lines (memorize briefly)

- “Gender and Married are **excluded from predictors** but kept for **audit** tables.”
- “SHAP explains **model associations**, not causal creditworthiness.”
- “We **do not retune** on the holdout; 123 rows are reserved once.”

---

## Page map (what to click)

| URL | Use in demo |
|-----|-------------|
| `/` | Homepage story — use only if you have extra time |
| `/workspace` | Dataset size, metrics, model comparison |
| `/assessment` | **Primary live scoring + SHAP** |
| `/batch` | CSV upload; sample file: `data/demo/presentation_batch.csv` |
| `/evidence` | Confusion matrix, ROC, fairness-style audits |
| `/methodology` | Preprocessing + evaluation narrative |

Optional second UI: `streamlit run app/app.py` on port **8501** (only if examiner asks for Streamlit).

---

## If something breaks during demo

| Symptom | Fix |
|---------|-----|
| `No module named sklearn` | Activate `.venv` or run `pip install -r requirements-lock.txt` |
| Raw data error | `python -m src.download_data` |
| Port 8000 busy | `python -m web --port 8080` and open `http://127.0.0.1:8080` |
| SHAP slow | First request after start may take a few seconds — run one example **before** the room fills |
| Script execution blocked | `Set-ExecutionPolicy -Scope Process RemoteSigned` |

API docs (backup): **http://127.0.0.1:8000/api/docs**

---

## Files to mention as evidence (no need to open all)

- `docs/STATUS_UPDATE.md` — eight-section project status for faculty
- `notebooks/01_eda.ipynb` — training-only EDA
- `models/best_model.joblib` + `reports/metrics.json`
- `docs/VIVA_NOTES.md` — 20 Q&A

---

## After presentation

Press **Ctrl+C** in the server terminal to stop LoanLens.