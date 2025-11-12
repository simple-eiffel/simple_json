note
	description: "Examples demonstrating type introspection features"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	TYPE_INTROSPECTION_EXAMPLES

create
	make

feature {NONE} -- Initialization

	make
			-- Run all examples
		do
			example_basic_type_check
			example_safe_value_extraction
			example_type_validation
		end

feature -- Examples

	example_basic_type_check
			-- Demonstrate basic type checking
		local
			l_json: SIMPLE_JSON
			l_obj: detachable SIMPLE_JSON_OBJECT
		do
			create l_json
			l_obj := l_json.parse ("{%"name%": %"Alice%", %"age%": 30}")

			if attached l_obj as al_obj then
				if al_obj.has_key ("name") then
					print ("Name exists in object%N")
				end

				if al_obj.has_key ("age") then
					print ("Age exists in object%N")
				end
			end
		end

	example_safe_value_extraction
			-- Demonstrate safe value extraction with type checking
		local
			l_json: SIMPLE_JSON
			l_obj: detachable SIMPLE_JSON_OBJECT
		do
			create l_json
			l_obj := l_json.parse ("{%"name%": %"Bob%", %"age%": 25}")

			if attached l_obj as al_obj then
				if al_obj.has_key ("name") then
					if attached al_obj.string ("name") as al_name then
						print ("Name: " + al_name + "%N")
					end
				end

				if al_obj.has_key ("age") then
					print ("Age: " + al_obj.integer ("age").out + "%N")
				end
			end
		end

	example_type_validation
			-- Demonstrate type validation before processing
		local
			l_json: SIMPLE_JSON
			l_obj: detachable SIMPLE_JSON_OBJECT
		do
			create l_json
			l_obj := l_json.parse ("{%"config_file%": %"settings.json%"}")

			if attached l_obj as al_obj then
				if al_obj.has_key ("config_file") then
					if attached al_obj.string ("config_file") as al_config then
						print ("Configuration file: " + al_config + "%N")
					end
				else
					print ("Error: config_file not found%N")
				end
			end
		end

end
