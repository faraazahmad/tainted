# frozen_string_literal: true

a = params[:insecure]
b = a + 1
c = b + 2
d = b + c

sql = "select * from users where age = #{d};"
execute(sql)
