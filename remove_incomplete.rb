class RemoveIncomplete

	if ARGV.length < 2 || ARGV.length > 4
		puts "Usage: filepath_to_parse filepath_to_save (options)"
		puts "\t options: debug"
		puts "\t\t debug shows in detail the process of eliminating incomplete questionnaires"

  else 

		file_to_parse = File.new(ARGV[0])
		file_to_save = File.new(ARGV[1], 'w')
		
		@DEBUG = true if ARGV[2] == "debug" if ARGV.length == 3

	 
		rows = file_to_parse.readlines

		regexp = Regexp.new('^[0-9]+') # Helps us select the number at the start of line

		# Arrays 

		@header_tmp_arr = []
		@rows_tmp_arr = []
		@valid_rows_arr = [] 

		# Question indices

		@new_question_n = nil       	
		@last_question_n = 0       

		def self.debug(which_case, row)
			puts "ROW\t" + row
			puts "\t\tCASE #{which_case}"
			puts "\t\tLAST_QUESTION_N:\t#{@last_question_n}"  
			puts "\t\tNEW_QUESTION_N: \t#{@new_question_n}"
			puts "\t\tHEADER_TMP"
			@header_tmp_arr.each { |header| puts "\t\t\t" + header}
			puts "\t\tROWS_TMP"
			@rows_tmp_arr.each { |row| puts "\t\t\t" + row}
			puts "\t\tVALID_ROWS"
			@valid_rows_arr.each { |row| puts "\t\t\t" + row }

		end

		rows.each do |row|
			
			# Find first word of each line
			match = regexp.match(row)
			@new_question_n = (match.nil? ? nil : match[0].to_i)

			# Line without a question number.	

			if @new_question_n.nil?
				@header_tmp_arr = []
				@header_tmp_arr << row   
				@rows_tmp_arr = []
				@last_question_n = 0

				self.debug("ONE", row) if @DEBUG

			# Are the two indices in between 1-32 (exclusive)
			# and are they increasing properly?
			# Or are we at the start of the loop or
			# did last line not have any question index?

			elsif @new_question_n > @last_question_n && 
				 @last_question_n < 32 || @last_question_n == 0 

				@rows_tmp_arr << row
				
				debug("TWO", row) if @DEBUG

				@last_question_n = @new_question_n

				# Successful block of rows 1-32
				# Did the new question number roll back to 1
				# with the last question number reaching 32?

				if @last_question_n == 32

					@header_tmp_arr.each { |header| @valid_rows_arr << header }
				 	@rows_tmp_arr.each { |valid_row| @valid_rows_arr << valid_row }

				 	@header_tmp_arr = []
					@rows_tmp_arr = []  
					@last_question_n = @new_question_n

					debug("THREE: SUCCESS", row) if @DEBUG

					@last_question_n = 0
				end


			# Did the new question number roll back to 1
			# without the last question number reaching
			# 32?

			elsif @new_question_n < @last_question_n && 
				    @last_question_n < 32

			 	@header_tmp_arr = []
				@rows_tmp_arr = []
				@rows_tmp_arr << row
				@last_question_n = @new_question_n
				
				debug("FOUR", row) if @DEBUG
			else
				debug("SOMETHING IS WRONG", row) if @DEBUG
			end
		end

		@valid_rows_arr.each do |row| puts row 
		file_to_save << row
		end
	end
end



