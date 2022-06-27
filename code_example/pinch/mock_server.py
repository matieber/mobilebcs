from flask import Flask, request
import time, sys, socket, json
import logging
from datetime import datetime


logger = logging.Logger('catch_all')
logged_users=[]
try:
	with open('users.txt') as json_file:
		registered_users=json.load(json_file)
		print(registered_users)
except:
	registered_users={}

try:
	with open('users_data.txt') as json_file:
		users_data=json.load(json_file)
		print(users_data)
except:
	users_data={}

server=Flask(__name__)


@server.route('/credit', methods=['GET'])
def credit():
	try:
		email = request.args.get('email') #TODO: cambiar email por un token de sesión activa
		response = {"earned": -1, "bought": -1, "message": ""}
		if email in logged_users:
			print(str(email)+" want to know its credit")
			if users_data[email]["navigation"] == "started":
				if users_data[email]["earnedCredit"] > 0:
					users_data[email]["earnedCredit"] = int(users_data[email]["earnedCredit"]) - 1 #this line is a simplification of accounting available credit
			response = {"earned": users_data[email]["earnedCredit"], "bought": users_data[email]["boughtCredit"], "message": ""}
			#the following lines must be placed as part of the method that updates the credit of the user
			with open('users_data.txt', 'w') as outfile:
				json.dump(users_data, outfile)
	except Exception as e:
		print("Exception occurred while processing credit GET request")
		logger.error(e, exc_info=True)
	finally:
		return json.dumps(response, ensure_ascii=False)

@server.route('/credit', methods=['POST'])
def creditpost():
	try:
		email = request.form.get('email') #TODO: cambiar email por un token de sesión activa
		method = request.form.get('method')
		amount = request.form.get('amount')
		response = {"status": amount, "message": "credit accounted"}
		if email in logged_users:
			print(str(email)+" modifies her credits in "+ str(amount)+". Now it is: bought="+str(users_data[email]["boughtCredit"])+" earned="+str(users_data[email]["earnedCredit"]))
			if users_data[email]["navigation"] == "started":
				if method == "ads":
					users_data[email]["earnedCredit"] = int(users_data[email]["earnedCredit"]) + int(amount)
				else:
					users_data[email]["boughtCredit"] = int(users_data[email]["boughtCredit"]) + int(amount)
		with open('users_data.txt', 'w') as outfile:
			json.dump(users_data, outfile)
	except Exception as e:
		print("Exception occurred while processing credit POST request")
		logger.error(e, exc_info=True)
	finally:
		return json.dumps(response, ensure_ascii=False)

@server.route('/status', methods=['GET'])
def statusmac():
	try:
		email = request.args.get('email') #TODO: cambiar email por un token de sesión activa
		response = {"session_id":"e053520cb3fc56d3a0b404cb51ff2da4af35ff1a", "message": ""}		
	except Exception as e:
		print("Exception occurred while processing credit GET request")
		logger.error(e, exc_info=True)
	finally:
		return json.dumps(response, ensure_ascii=False)


@server.route('/navigation', methods=['POST'])
def navigation():
	try:
		email = request.args.get('email') #TODO: cambiar email por un token de sesión activa
		dt_string = now.strftime("%b-%d-%Y %H:%M:%S")
		response = {"value": 0, "timestamp": str(dt_string), "message": ""}
		if email in logged_users:
			action = request.args.get('action')  # indicates whether the user starts or ends navigation.
			users_data[email]["navigation"] = action
			print(str(email) + ' - ' + str(action) + ' navigation')
			response = {"value": 1, "timestamp": str(dt_string), "message": ""}
	except Exception as e:
		print(str(e.__traceback__))
		print(str(email)+" not logged in")
	finally:
		return json.dumps(response, ensure_ascii=False)

@server.route('/redeemcodelogin', methods=['POST'])
def useRedeemCode():
	try:
		redeemCode = request.form.get('redeemCode')
		#TODO: chequear validez del redeem code y enviar respuesta acorde
		print("intento de navegación con redeem code: " + str(redeemCode))
		if redeemCode == "55555":
			response = {"value": 1, "message": "Código de canje aceptado"}
		else:
			response = {"value": 0, "message": "Su código canjeable expiró o es inválido"}
	except Exception as e:
		print(str(e.__traceback__))
	finally:
		return json.dumps(response, ensure_ascii=False)

@server.route('/login',methods=['POST'])
def login():
	email = request.form.get('email')
	password = request.form.get('password')
	redeemCode = request.form.get('redeemCode')
	# already logged in
	if email in logged_users:
		fullName = registered_users[email]["fullName"]
		return json.dumps({"value": 1, "fullNameAPI": fullName, "message": ""}, ensure_ascii=False)
	success = 1 if email in registered_users.keys() else 0
	message = "Usuario validado exitosamente" if success == 1 else "El intento de ingreso ha fallado"
	fullName = registered_users[email]["fullName"]	if success == 1 else ""
	if success:
		if registered_users[email]["password"] == password:
			logged_users.append(email)
		else:
			success = 0
			message = "El intento de ingreso ha fallado"
	return json.dumps({"value": success, "fullNameAPI": fullName, "message": message}, ensure_ascii=False)
	
@server.route('/register',methods=['POST'])
def register():
	full_name = request.form.get('fullName')
	email = request.form.get('email')
	password = request.form.get('password')
	success = 1 if not email in registered_users.keys() else 0
	message = "Usuario registrado exitosamente" if success == 1 else "E-mail ya utilizado: " + email
	if success:
		registered_users[email] = {"fullName": full_name, "password": password}
		with open('users.txt', 'w') as outfile:
			json.dump(registered_users, outfile)
	return json.dumps({"value": success, "message": message}, ensure_ascii=False)

def getip():
	s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
	try:
		# doesn't even have to be reachable
		s.connect(('10.255.255.255', 1))
		IP = s.getsockname()[0]
	except Exception:
		IP = '127.0.0.1'
	finally:
		s.close()
	return IP

server.run(getip(), port=5555)

