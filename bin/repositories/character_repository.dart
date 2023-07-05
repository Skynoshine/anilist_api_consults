class CharacterRepository {
  String getQuery({required String name}) {
    return '''
    query {
      Character(search: "$name") {
        id
        name {
          full
        }
        gender
        age
        description(asHtml: false)
        dateOfBirth {
          year
          month
          day
        }
        media {
          nodes {
            title {
              english
            }
          }
        }
      }
    }
  ''';
  }
}
