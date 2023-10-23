# frozen_string_literal: true

a = tainted()
b = a + 1
c = b + 2
d = b + c
unsafe(d)
unsafe(c)
