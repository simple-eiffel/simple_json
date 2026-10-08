note
	description: "[
		Deferred class for entities that can serialize to/from JSON.

		Inherit from this class and implement `to_json` and `make_from_json`
		to enable automatic JSON serialization for your entity classes.

		Example:
			class MY_ENTITY
			inherit
				SIMPLE_JSON_SERIALIZABLE

			feature -- JSON
				to_json: SIMPLE_JSON_OBJECT
					do
						create Result.make
						Result.put_integer (id, "id")
						Result.put_string (name, "name")
					end

				make_from_json (a_json: SIMPLE_JSON_OBJECT)
					do
						id := a_json.integer_item ("id")
						if attached a_json.string_item ("name") as n then
							name := n.to_string_8
						end
					end

				json_has_required_fields (a_json: SIMPLE_JSON_OBJECT): BOOLEAN
					do
						Result := a_json.has_all_keys (<<"id", "name">>)
					end
			end
	]"
	author: "Claude Code"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	SIMPLE_JSON_SERIALIZABLE

feature -- JSON Serialization

	to_json: SIMPLE_JSON_OBJECT
			-- Convert this entity to a JSON object.
		deferred
		ensure
			result_attached: Result /= Void
		end

feature -- JSON Deserialization

	apply_json (a_json: SIMPLE_JSON_OBJECT)
			-- Apply JSON values to this entity (for updates).
			-- Override to customize which fields are applied.
		require
			json_attached: a_json /= Void
		deferred
		end

feature -- Validation

	json_has_required_fields (a_json: SIMPLE_JSON_OBJECT): BOOLEAN
			-- Does `a_json` have all fields required to create/update this entity?
			-- Override to specify required fields.
		require
			json_attached: a_json /= Void
		deferred
		end

	json_missing_fields (a_json: SIMPLE_JSON_OBJECT): ARRAYED_LIST [STRING_32]
			-- Which required fields are missing from `a_json`?
			-- Default implementation returns empty list - override with required_fields.
		require
			json_attached: a_json /= Void
		do
			create Result.make (0)
		ensure
			result_attached: Result /= Void
		end

feature -- Convenience

	to_json_string: STRING_32
			-- JSON representation as string.
		do
			Result := to_json.representation
		ensure
			result_attached: Result /= Void
		end

	to_json_string_8: STRING_8
			-- JSON representation as STRING_8.
		do
			Result := to_json.representation.to_string_8
		ensure
			result_attached: Result /= Void
		end

note
	copyright: "Copyright (c) 2025, Larry Rix"
	license: "MIT License"

end
