class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    # reset_session
    @curret_uri = request.env['PATH_INFO']
    @sort_by = params[:sort_by]
    @all_ratings = Movie.all_ratings()
    @ratings = params[:ratings].nil? ? nil : params[:ratings].keys
    
    if @ratings.nil?
      if params[:commit] == "Refresh"
        @ratings = []
      else
        @ratings = session[:ratings].nil? ? @all_ratings : session[:ratings]
      end
    end

    need_redirect = (@ratings != session[:ratings] && !session[:ratings].nil?) || (@sort_by != session[:sort_by] && !session[:sort_by].nil?)

    if @sort_by == 'title' || @sort_by == 'release_date'
      nil
    elsif !session[:sort_by].nil?
      @sort_by = session[:sort_by]
    end
    @movies = Movie.with_ratings_sorted(@ratings, @sort_by)

    # Remember params
    session[:ratings] = @ratings
    session[:sort_by] = @sort_by
    # restore route
    if need_redirect
      redirect_to movies_path(:sort_by => @sort_by, :ratings => @ratings.map{ |x| [x, 1]}.to_h)
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
