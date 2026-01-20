note
	description: "Test helper class for serializer tests"

class
	TEST_SERIALIZER_PERSON

create
	make,
	make_with_address

feature {NONE} -- Initialization

	make (a_name: STRING; a_age: INTEGER)
			-- Create with name and age.
		do
			name := a_name
			age := a_age
		ensure
			name_set: name = a_name
			age_set: age = a_age
		end

	make_with_address (a_name: STRING; a_age: INTEGER; a_address: TEST_SERIALIZER_ADDRESS)
			-- Create with name, age, and address.
		do
			name := a_name
			age := a_age
			address := a_address
		ensure
			name_set: name = a_name
			age_set: age = a_age
			address_set: address = a_address
		end

feature -- Access

	name: STRING
			-- Person's name.

	age: INTEGER
			-- Person's age.

	address: detachable TEST_SERIALIZER_ADDRESS
			-- Person's address (optional).

end
