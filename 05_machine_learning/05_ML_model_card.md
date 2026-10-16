# Late Baggage Case Predictor: Model Card

**Task:** predict whether a mishandled-baggage case will be closed late (past its target days) from issue type, connecting passenger, whether the bag was found at the first station, and season.

**Data:** 1500 simulated cases (Oct 2014 - Mar 2019); 58.4% closed late. Simulated, so results show the method, not real airline performance.

**Baseline (always predict the majority class):** 0.584 accuracy

| Model | Accuracy | Precision | Recall | F1 |
|---|---|---|---|---|
| Logistic Regression | 0.733 | 0.822 | 0.694 | 0.752 |
| Random Forest | 0.728 | 0.806 | 0.703 | 0.751 |

**Reading it:** compare accuracy to the baseline, not to 100%. Recall matters most here, because the point is to catch cases likely to run late so someone can chase them early.
