require 'open-uri'
require 'json'

class GamesController < ApplicationController

  # This action runs when the user visits /new
  def new
    # We generate an array of 10 random uppercase letters (from A to Z)
    @letters = Array.new(10) { ('A'..'Z').to_a.sample }
  end

  # This action runs when the user submits the form
  def score
    # Get the word the user typed, and make it uppercase
    @word = params[:word].upcase

    # Split the string of letters (like "A B C") into an array of letters
    @letters = params[:letters].split('')

    # Get the start and end time of the game
    @start_time = params[:start_time].to_i
    @end_time = Time.now.to_i
    @time_taken = @end_time - @start_time

    # First, check if the word uses the correct letters
    if !word_in_grid?(@word, @letters)
      @result = "Sorry but #{@word} can’t be built from these #{@letters}"
      @score = 0

    # Next, check if it's a real English word
    elsif !english_word?(@word)
      @result = "Sorry but ❌ #{@word} does not seem to be a valid English word..."
      @score = 0

    # If the word passes both tests, it's valid!
    else
      @result = "✅ Congratulations! #{@word} is a valid English word!"
      @score = calculate_score(@word, @time_taken)

      # Save the score across games using the session
      session[:total_score] ||= 0
      session[:total_score] += @score
    end

    # Show the total score (across all rounds)
    @total_score = session[:total_score]
  end

  private

  # Check if the word only uses the letters from the grid
  def word_in_grid?(word, letters)
    word.chars.all? do |letter|
      word.count(letter) <= letters.count(letter)
    end
  end

  # Check if the word is a valid English word using an online API
  def english_word?(word)
    url = "https://wagon-dictionary.herokuapp.com/#{word}"

    begin
      response = URI.open(url).read
      data = JSON.parse(response)
      return data['found'] # This will be true or false
    rescue OpenURI::HTTPError => e
      puts "Error with the dictionary API: #{e.message}"
      return false
    end
  end

  # Calculate the user's score
  def calculate_score(word, time_taken)
    word.length * 10 - time_taken
  end
end
