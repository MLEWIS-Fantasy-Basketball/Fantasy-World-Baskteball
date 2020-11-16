from flask import Flask, render_template, request, redirect, url_for, jsonify, abort
from flask_sqlalchemy import SQLAlchemy
#from flask_migrate import Migrate
import sys

app = Flask(__name__) 
# config the SQLAlchemy connection to the database as your own database
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://postgres:stevenmarquez@localhost:5432/todoapp'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app) 

migrate = Migrate(app, db)

class Team(db.Model):
    __tablename__ = 'team' # specify the table name if it is different from class name
    id = db.Column(db.Integer, primary_key=True) # define ID 
    owner_id = db.Column(db.Integer, nullable=False)
    name = db.Column(db.String(), nullable=False) # define description
    wins = db.Column(db.Integer, nullable=False)
    losses = db.Column(db.Integer, nullable=False)
    player_ids = db.Column(db.Integer)
    #completed = db.Column(db.Boolean, nullable=False, default=False)
    list_id = db.Column(db.Integer, db.ForeignKey('team.team_id'), nullable=False)

    # for debug print object information purpose
    def __repr__(self):
        return f'<Team: ID {self.id}, description {self.description}, listID {self.list_id}>'


class TeamList(db.Model):
    __tablename__ = 'teamlists'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(), nullable=False)
    player_ids = db.relationship('Players', backref='list', cascade='all, delete-orphan', lazy=True)

    def __repr__(self):
        return f'<TeamList: ID {self.league_id}, name {self.name}>'

class Player(db.Model):
    __tablename__ = 'team' # specify the table name if it is different from class name
    id = db.Column(db.Integer, primary_key=True) # define ID 
    name = db.Column(db.String(), nullable=False) # define description
    on_team = db.Column(db.Boolean, nullable=False)
    position = db.Column(db.String(), nullable=False)
    real_team_name = db.Column(db.String(), nullable=False)
    real_league_name = db.Column(db.String(), nullable=False)
    #completed = db.Column(db.Boolean, nullable=False, default=False)
    list_id = db.Column(db.Integer, db.ForeignKey('player.player_id'), nullable=False)

    # for debug print object information purpose
    def __repr__(self):
        return f'<Team: ID {self.id}, description {self.description}, listID {self.list_id}>'


class PlayerList(db.Model):
    __tablename__ = 'teamlists'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(), nullable=False)
    player_id = db.relationship('Player', backref='list', cascade='all, delete-orphan', lazy=True)

    def __repr__(self):
        return f'<PlayerList: ID {self.id}, name {self.name}>'



#db.create_all() # create database based on class definition

@app.route('/teams/create', methods=['POST'])
def create_team():
    # description = request.form.get('description')
    # if not description:
    #     description = 'Do Nothing'
    # todo = Todo(description = description)
    # db.session.add(todo)
    # db.session.commit()
    # return redirect(url_for('index'))
    error = False
    body = {}
    try:
        name = request.get_json()['teamName']
        #list_id = request.get_json()['list_id']
        #if not name:
            #description = 'Do Nothing'
        team = Team(name = name)
        #body['description'] = todo.description
        db.session.add(team)
        db.session.commit()
        body['league_id'] = team.league_id
        body['name'] = team.name
    except:
        error = True
        db.session.rollback()
        print(sys.exc_info())
    finally:
        db.session.close()
    if error:
        abort(400)
    else:
        return jsonify(body)
        #      return jsonify({
        #     'description': todo.description
        # })

@app.route('/teams/<team_id>/delete', methods=['DELETE'])
def delete_todo(team_id):
    error = False
    try:
        Team.query.filter_by(id=team_id).delete()
        db.session.commit()
    except:
        db.session.rollback()
        error = True
    finally:
        db.session.close()
    if error:
        abort(400)
    else:
        return jsonify({'success': True})

@app.route('/teams/<team_id>/set-completed', methods=['POST'])
def set_completed_team(todo_id):
    error = False
    try:
        completed = request.get_json()['completed']
        team = Team.query.get(todo_id)
        team.completed = completed
        db.session.commit()
    except:
        db.session.rollback()
        error = True
    finally:
        db.session.close()
    if error:
        abort(400)
    else:
        return '', 200

@app.route('/')
def index():
    return redirect(url_for('get_list_teams', list_id=1))

@app.route('/lists/<list_id>') # tell Flask what URL should trigger the function
# the function is given a name which is used to generate URLs for that particular function and returns the message we want to display in browser, function name does not matter
def get_list_teams(list_id):
    lists = TeamList.query.all()
    active_list = TeamList.query.get(list_id)
    teams = Team.query.filter_by(list_id=list_id).order_by('team_id').all()
    
    return render_template('index.html',todos=todos, lists=lists, active_list=active_list)

@app.route('/lists/create', methods=['POST'])
def create_team():
    error = False
    body = {}
    try:
        name = request.get_json()['name']
        if not name:
            name = 'Causal'
        teamlist = TeamList(name=name)
        db.session.add(todolist)
        db.session.commit()
        body['team_id'] = teamlist.id
        body['name'] = teamlist.name
    except:
        error = True
        db.session.rollback()
        print(sys.exc_info())
    finally:
        db.session.close()
    if error:
        abort(400)
    else:
        return jsonify(body)



@app.route('/lists/<list_id>/delete', methods=['DELETE'])
def delete_list(list_id):
    error = False
    try:
        list = TeamList.query.get(list_id)
        for teams in list.teams:
            db.session.delete(todo)
        
        db.session.delete(list)
        db.session.commit()
    except:
        db.session.rollback()
        error = True
    finally:
        db.session.close()
    if error:
        abort(400)
    else:
        return jsonify({'success': True})

@app.route('/lists/<list_id>/set-completed', methods=['POST'])
def set_completed_list(list_id):
    error = False
    try:
        list = TeamList.query.get(list_id)
        set_completed = request.get_json()['set_completed']

        for team in list.teams:
            todo.completed = set_completed
        db.session.commit()
    except:
        db.session.rollback()
        error = True
    finally:
        db.session.close()
    if error:
        abort(400)
    else:
        return '', 200



@app.route('/players/create', methods=['POST'])
def create_player():
    # description = request.form.get('description')
    # if not description:
    #     description = 'Do Nothing'
    # todo = Todo(description = description)
    # db.session.add(todo)
    # db.session.commit()
    # return redirect(url_for('index'))
    error = False
    body = {}
    try:
        name = request.get_json()['playerName']
        #list_id = request.get_json()['list_id']
        #if not name:
            #description = 'Do Nothing'
        player = player(name = name)
        #body['description'] = todo.description
        db.session.add(player)
        db.session.commit()
        body['player_id'] = player.id
        body['name'] = player.name
    except:
        error = True
        db.session.rollback()
        print(sys.exc_info())
    finally:
        db.session.close()
    if error:
        abort(400)
    else:
        return jsonify(body)
        #      return jsonify({
        #     'description': todo.description
        # })

@app.route('/Players/<player_id>/delete', methods=['DELETE'])
def delete_player(team_id):
    error = False
    try:
        Player.query.filter_by(id=player_id).delete()
        db.session.commit()
    except:
        db.session.rollback()
        error = True
    finally:
        db.session.close()
    if error:
        abort(400)
    else:
        return jsonify({'success': True})

@app.route('/players/<player_id>/set-completed', methods=['POST'])
def set_completed_team(player_id):
    error = False
    try:
        completed = request.get_json()['completed']
        player = Team.query.get(player_id)
        player.completed = completed
        db.session.commit()
    except:
        db.session.rollback()
        error = True
    finally:
        db.session.close()
    if error:
        abort(400)
    else:
        return '', 200

@app.route('/')
def index():
    return redirect(url_for('get_list_players', list_id=1))

@app.route('/lists/<list_id>') # tell Flask what URL should trigger the function
# the function is given a name which is used to generate URLs for that particular function and returns the message we want to display in browser, function name does not matter
def get_list_teams(list_id):
    lists = PlayerList.query.all()
    active_list = PlayerList.query.get(list_id)
    player = Player.query.filter_by(list_id=list_id).order_by('player_id').all()
    
    return render_template('index.html',players=player, lists=lists, active_list=active_list)

@app.route('/lists/create', methods=['POST'])
def create_player():
    error = False
    body = {}
    try:
        name = request.get_json()['name']
        if not name:
            name = 'Causal'
        playerlist = TeamList(name=name)
        db.session.add(todolist)
        db.session.commit()
        body['player_id'] = playerlist.id
        body['name'] = playerlist.name
    except:
        error = True
        db.session.rollback()
        print(sys.exc_info())
    finally:
        db.session.close()
    if error:
        abort(400)
    else:
        return jsonify(body)



@app.route('/lists/<list_id>/delete', methods=['DELETE'])
def delete_list(list_id):
    error = False
    try:
        list = PlayerList.query.get(list_id)
        for player in list.players:
            db.session.delete(todo)
        
        db.session.delete(list)
        db.session.commit()
    except:
        db.session.rollback()
        error = True
    finally:
        db.session.close()
    if error:
        abort(400)
    else:
        return jsonify({'success': True})

@app.route('/lists/<list_id>/set-completed', methods=['POST'])
def set_completed_list(list_id):
    error = False
    try:
        list = PlayerList.query.get(list_id)
        set_completed = request.get_json()['set_completed']

        for player in list.players:
            todo.completed = set_completed
        db.session.commit()
    except:
        db.session.rollback()
        error = True
    finally:
        db.session.close()
    if error:
        abort(400)
    else:
        return '', 200

