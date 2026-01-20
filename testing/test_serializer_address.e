note
	description: "Test helper class for serializer tests"

class
	TEST_SERIALIZER_ADDRESS

create
	make

feature {NONE} -- Initialization

	make (a_street, a_city: STRING)
			-- Create with street and city.
		do
			street := a_street
			city := a_city
		ensure
			street_set: street = a_street
			city_set: city = a_city
		end

feature -- Access

	street: STRING
			-- Street address.

	city: STRING
			-- City name.

end
