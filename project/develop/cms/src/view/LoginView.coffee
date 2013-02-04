class LoginView extends Backbone.View

    el : $(".wrapper")

    params : { action: "/api/user/login" }

    initialize: =>

        @render()

    render: =>

        localview = _.template view.oz.templates.get "login"
        $(@el).append localview @params

        @initForm()

    initForm: =>

        $("#login").ajaxForm { dataType: "json", success: @processJson, error: @onError }
        
        $(".login-box .form div input[type='text']").keyup @onChange
        $(".login-box .form div input[type='password']").keyup @onChange

    processJson: ( data ) =>

        # Debug

        unless data.result?
            @onError(data)
            return

        view.oz.role = data.result.role

        switch view.oz.role
            when 0, 1
                view.oz.appRouter.navigateTo HeaderView.buttons[0].id

            else 
                view.oz.appRouter.navigateTo HeaderView.buttons[2].id


    onError: ( data ) =>

        $(".login-box .form div input[type='text']").addClass "error"
        $(".login-box .form div input[type='password']").addClass "error"

    onChange: =>
        
        $(".login-box .form div input[type='text']").removeClass "error"
        $(".login-box .form div input[type='password']").removeClass "error"