note
	description: "Test helper class for serializer tests - parent with children"

class
	TEST_SERIALIZER_PARENT_WITH_CHILDREN

create
	make_with_children

feature {NONE} -- Initialization

	make_with_children (a_name: STRING; a_child_count: INTEGER)
			-- Create with name and specified number of children.
		local
			i: INTEGER
			l_child: TEST_SERIALIZER_PERSON
		do
			name := a_name
			create children.make (a_child_count)
			from i := 1 until i > a_child_count loop
				create l_child.make ("Child" + i.out, 10 + i)
				children.extend (l_child)
				i := i + 1
			end
		ensure
			name_set: name = a_name
			children_count: children.count = a_child_count
		end

feature -- Access

	name: STRING
			-- Parent name.

	children: ARRAYED_LIST [TEST_SERIALIZER_PERSON]
			-- Children list.

end
