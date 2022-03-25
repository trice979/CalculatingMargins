DECLARE @startDate DATE = '2020-07-01'
DECLARE @endDate DATE = '2021-12-31';

WITH			ORProvider AS (		
SELECT			sc.HospitalAccount ,	
                	sc.Prov_ID_Legacy ,	
			sum(cast(sc.ORTIME as float)) ORTime ,	
			ROW_NUMBER() OVER(PARTITION BY sc.HospitalAccount ORDER BY sc.HospitalAccount , sum(cast(sc.ORTIME as float)) DESC) as Row#	
FROM			DSS..SurgCases sc	
group by		sc.HospitalAccount ,			
			sc.Prov_ID_Legacy)	

,			PrimProv AS (	
SELECT			*		
FROM			ORProvider		
WHERE			ORProvider.Row# = 1)	

SELECT			enc.EncounterID ,	
			enc.PatientType	,
			enc.AdmissionDate ,	
			enc.DischargeDate ,	
			dt.year_fiscal ,
                	FORMAT(enc.DischargeDate, 'yyyy-MM') DischargeMonth ,	
			enc.TotalCharges ,	
			ISNULL(enc.TotalActualPayment, 0) TotalActualPayment, 
                	enc.VariableDirectCost ,	
			enc.FixedDirectCost ,	
			enc.VariableIndirectCost ,	
			enc.FixedIndirectCost ,	
			ISNULL(enc.TotalActualPayment, 0) - enc.TotalDirectCosts DirectMargin ,	
			ISNULL(enc.TotalActualPayment, 0) - enc.TotalVariableCosts Contribution ,	
			ISNULL(enc.TotalActualPayment, 0) - enc.TotalCosts NetIncome ,
			enc.ARBalance ,
			udf.Description FinancialClass ,	
			ps.Prov_ID_Legacy ,
                	ph.last_name + ', ' + ph.first_name SurgeonName ,
                	ph.Division AcademicDept ,
                	ph.Specialty Division
					
FROM			T_IP_ENCOUNTER enc		
INNER JOIN      	DSS..DATE dt
                    		on enc.DischargeDate = dt.date
INNER JOIN		PrimProv ps			
				ON enc.PatientAccount = ps.HospitalAccount
LEFT JOIN		T_UDF_DESCRIPTION_8 udf			
				on enc.UserField2 = udf.Code
LEFT JOIN       	DSS..PHYSICIAN ph
                    		on ps.Prov_ID_Legacy = ph.physician_number

WHERE			enc.DischargeDate BETWEEN @startDate AND @endDate	

ORDER BY		enc.TotalActualPayment - enc.TotalVariableCosts DESC			
