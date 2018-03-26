require 'net/ldap'
class LdapController < ApplicationController

  def connect

    ldap = Net::LDAP.new(
      host: 'openldap',
      port: 389,
      auth: {
        method: :simple,
        dn: "cn=admin,dc=arqsoft,dc=unal,dc=edu,dc=co",
        password: "admin"
      }
    )
    return ldap.bind
  end


  def create 
    email = params[:email]
    password = params[:password]
    email = email[/\A\w+/].downcase

    if connect()
      
      ldap = Net::LDAP.new(
        host: 'openldap',
        port: 389,
        auth: {
          method: :simple,
          dn: "cn=" + email + "@unal.edu.co, ou=Academy,dc=arqsoft,dc=unal,dc=edu,dc=co",
          password: password
        }
      )

      if ldap.bind
        query = "select * from students where email LIKE '" + email + "@unal.edu.co'"
        results = ActiveRecord::Base.connection.exec_query(query)
        if results.present?
          @newAuth = ObjAuth.new(email, password, "true")
          puts("Ingresó correctamente")
          render json: @newAuth
        else
          puts("No ingresó no está en DB")
          @newAuth = ObjAuth.new(email, password, "false")
          render json: @newAuth
        end
      else
        puts("No ingresó no está en LDAP")
        @newAuth = ObjAuth.new(email, password, "false")
        render json: @newAuth
      end

    end

  end
end

class ObjAuth
  def initialize(email, password, answer)
    @email = email
    @password = password
    @answer = answer
  end
end