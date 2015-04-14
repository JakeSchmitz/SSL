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
		if @doc.nil?
			redirect_to doc_index_path, notice: 'No record of doc with id: ' + params[:id].to_s  
		end
	end

        def raw
		@raw = ssl.find({id: params[:id]}).to_a.first
		if @raw.nil?
			redirect_to doc_index_path, notice: 'No record of doc with id: ' + params[:id].to_s  
                else
                        render json: @raw 
		end
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
			@result = ''
		end
	end

	def create
		puts params
		if params[:new_doc_contents].nil?
			puts 'Failed to find new_doc_contents'
			redirect_to doc_find_path, notice: 'Could not find that doc'
		else
			new_doc = params[:new_doc_contents]
			new_doc['_id'] = new_doc['isbn']
			new_id = ssl.insert(new_doc)
			puts new_doc.to_s
			redirect_to doc_path(new_id), notice: 'Your document was successfully added to the SSL'
		end
	end

        def delete
                if current_user.try(:admin?)
                    puts params
                    if params[:id].nil?
                            puts 'Failed to find id'
                            redirect_to doc_index_path, notice: 'Could not delete that doc'
                    else
                            ssl.remove({'id': params[:id]})
                            redirect_to docs_path, notice: 'Your document was successfully deleted from the SSL'
                    end
                else
                    redirect_to root_path, alert: 'You do not have permission to delete entries from the SSL'
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
				flts["title"] = title
			end
			if params.has_key?(:author) and params[:author].match(/^[[:alnum:]\ ]+$/)
				flts["author"] = Regexp.union(params[:author].split(' ').map{|w| Regexp.new(w, true)})
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
				srt[:title] = 1
			end
			srt
		end
end
