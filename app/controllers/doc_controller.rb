require 'jsonclient'
require 'mongo'
include Mongo
require 'uri'

class DocController < ApplicationController
	def index
		@docs = ssl.find(filters).sort(sorted_by)
	end

	def show
		@doc = ssl.find({id: params[:id]}).to_a.first
	end

	def find
		clnt = JSONClient.new
		header = {'Cookie' => 'Summon-Two=true'}
		uri = URI.parse(URI.encode("http://tufts.summon.serialssolutions.com/api/search?pn=1&ho=t&q=" + params[:title]))
		response = clnt.get(uri,
												nil,
												header)
		json_response = response.content
		if json_response.keys.include?("documents")
			@result = response.content["documents"]
		else
			@result = nil
		end
	end

	def create
		if params[:new_doc_contents].nil?

		else

		end
	end

	private
		def ssl
			mongo_uri = ENV['SSL_MONGODB']
			db_name = mongo_uri[%r{/([^/\?]+)(\?|$)}, 1]
			client = MongoClient.from_uri(mongo_uri)
			db = client.db(db_name)
			db.collection('ssl')
		end

		def filters
			flts = {}
			if params.has_key?(:title) and params[:title].match(/^[[:alnum:]\ ]+$/)
				title = Regexp.new(params[:title].split(' ').map{|word| '(?=.*' << word << ')'}.join(''), true)
				flts["ssltitle"] = title
			end
			if params.has_key?(:author) and params[:author].match(/^[[:alnum:]\ ]+$/)
				flts["sslauthor"] = Regexp.union(params[:author].split(' ').map{|w| Regexp.new(w, true)})
			end
			if params.has_key?(:keywords) and params[:keywords].match(/^[[:alnum:]\ ]+$/)
				keywords = Regexp.union(params[:keywords].split(' ').map{|word| Regexp.new(word, true)})
				flts["subject_terms"] = keywords
			end
			if params.has_key?(:disciplines) and params[:disciplines].match(/^[[:alnum:]\ ]+$/)
				flts["disciplines"] = Regexp.union(params[:disciplines].split(' ').map{|word| Regexp.new(word, true)})
			end
			if params.has_key?(:publisher) and params[:publisher].match(/^[[:alnum:]\ ]+$/)
				flts["publisher"] = Regexp.new(params[:publisher], true)
			end
			if params.has_key?(:isbn) and not params[:isbn].nil?
				flts["isbn"] = Regexp.new(Regexp.escape(params[:isbn]), true)
			end
			flts
		end

		def sorted_by
			srt = {}
			if params.has_key?(:sort_by) and params[:sort_by].match(/^[[:alnum:]\ ]+$/)
				srt[params[:sort_by]] = 1
			else
				srt[:ssltitle] = 1
			end
			srt
		end
end
