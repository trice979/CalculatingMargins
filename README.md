# SurgeryMargins
Query calculate margins by department of surgeons using recursive CTE.

The first CTE (ORProvider) lists all the surgeons on the account.
The second CTE (PrimProv) attributes a primary provider to an account based on which surgeon logged the most surgery minutes on the account.

