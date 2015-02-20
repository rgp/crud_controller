module CrudController
  class Base < ::ApplicationController
    before_action :set_object, only: [:show, :edit, :update, :destroy]
    before_action :set_attributes, only: [:index, :new, :show, :edit, :create]
    before_action :set_collection, only: [:index]

    def show
    end

    def index
    end

    def new
      @object = model.new
    end

    def create
      @object = model.new(object_params)
      if @object.save
        flash[:success] = "#{model} guardado correctamente."
        redirect_to "/#{controller_name}"
      else
        flash[:warning] = "El #{model} no se pudo guardar."
        render :new
      end
    end

    def edit
    end

    def update
      if @object.update(object_params)
        redirect_to @object
        flash[:success] = "#{model} actualizado correctamente."
      else
        render :edit
        flash[:warning] = "Revise los datos del #{model}."
      end
    end

    def destroy
      if @object.destroy
        flash[:success] = "#{model} borrado correctamente."
        redirect_to "/#{controller_name}"
      else
        flash[:warning] = "#{@object.errors.messages[:base]}"
        set_collection
        set_attributes
        render :index
      end
    end

    private

    def set_collection
      if params[:search]
        value = params[:search]
        query = ""
        model_columns = model.column_names.select { |c| !c.end_with?('_id')}
        %w(id created_at updated_at deleted_at).each{|k| model_columns.delete(k)}
        model_columns.each.with_index do |column, index|
          if index != 0 
            query << " OR "
          end 
          query << "#{column} LIKE '%#{value}%'"
        end
        
        @search_param = params[:search]
        collection = model.where(query).paginate page: params[:page], 
                                                       per_page: 30
      else
        collection = model.paginate page: params[:page], per_page: 30
      end
      
      instance_variable_set "@#{controller_name}", collection
      @object_collection = collection
    end

    def model
      @klass ||= controller_name.singularize.camelize.constantize
    end

    def set_object
      object = model.find(params[:id])
      instance_variable_set "@#{controller_name.singularize}", object
      @object = object
    end

    def set_attributes
      @attributes = model.columns_hash.clone
      %w(id created_at updated_at deleted_at).each { |k| @attributes.delete(k) }
    end

    def object_params
      params.require(model.name.underscore.to_sym).permit(model.column_names)
    end
  end
end
