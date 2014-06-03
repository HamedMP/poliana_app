class PoliticiansController < ApplicationController
  before_filter :authenticate_user!

  def index
    @politicians = Politician.all

    @politicians = @politicians.where(:state => params[:state]) if params[:state].present?
    @politicians = @politicians.any_in(:party => params[:party].split(',')) if params[:party].present?
    @politicians = @politicians.where(:gender => params[:gender]) if params[:gender].present?
    @politicians = @politicians.any_in(:religion => params[:religion].split(',')) if params[:religion].present?

    if params[:time].present? || params[:type].present?
      found = []

      congress = params.fetch(:time, 0).to_i
      type = params.fetch(:type, "")

      @politicians.each do |politician|
        politician.terms.each do |term|
          if term.congresses.include? congress or term.term_type == type
            found.push(politician)
            break
          end
        end
      end

      @politicians = found
    end

    respond_to do |format|
      format.html
      format.json { render :json => @politicians.to_json }
    end
  end

  def show
    require 'wikipedia'

    @politician = Politician.where(:bioguide_id => params[:id].upcase).first

    wiki = Wikipedia.find(@politician.first_name + " " + @politician.last_name)
    if wiki.templates.first != "Template:Category handler"
      wikiNoko = Nokogiri::HTML(wiki.sanitized_content)
      @wikipediaBio = wikiNoko.search('p').first
    else
      @wikipediaBio = nil
    end
  end
end
