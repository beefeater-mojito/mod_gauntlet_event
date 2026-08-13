this.gauntlet_helper <- {
	function formatValue(v) {
		return typeof v == "string" ? "\"" + v + "\"" : v;
	}

	function dumpCustom(value, indent = "") {
		switch (typeof value) {
			case "table":
				this.logDebug(indent + "{");
				foreach (k, v in value) {
					if (typeof v == "table" || typeof v == "array") {
						this.logDebug(indent + "  " + k + " =");
						dumpCustom(v, indent + "  ");
					} else {
						this.logDebug(indent + "  " + k + " = " + this.formatValue(v));
					}
				}
				this.logDebug(indent + "}");
				break;

			case "array":
				this.logDebug(indent + "[");
				foreach (i, v in value) {
					if (typeof v == "table" || typeof v == "array") {
						this.logDebug(indent + "  [" + i + "] =");
						dumpCustom(v, indent + "  ");
					} else {
						this.logDebug(indent + "  [" + i + "] = " + this.formatValue(v));
					}
				}
				this.logDebug(indent + "]");
				break;

			default:
				this.logDebug(indent + this.formatValue(value));
				break;
		}
		return "Dump done!"
	}
}
