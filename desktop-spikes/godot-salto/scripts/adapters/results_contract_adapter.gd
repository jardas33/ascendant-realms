extends RefCounted
class_name ResultsContractAdapter

func validate_adapter(results_contract: Dictionary) -> Dictionary:
	var errors: Array[String] = []
	var required_fields: Array = results_contract.get("requiredFields", [])
	for field in ["outcome", "objective summary", "no-save marker", "Lume summary", "return action"]:
		if not required_fields.has(field):
			errors.append("Results contract missing required field: %s" % field)
	if results_contract.get("saveMutationAllowed", true) != false:
		errors.append("Results contract allows save mutation.")
	if results_contract.get("rewardMutationAllowed", true) != false:
		errors.append("Results contract allows reward mutation.")
	if results_contract.get("localStorageMutationAllowed", true) != false:
		errors.append("Results contract allows localStorage mutation.")
	return {
		"schemaVersion": 1,
		"adapter": "ResultsContractAdapter",
		"status": "PASS" if errors.is_empty() else "FAIL",
		"errors": errors,
		"requiredFields": required_fields,
		"resultsTransitionRequired": true,
		"saveMutationAllowed": false,
		"localStorageMutationAllowed": false
	}
