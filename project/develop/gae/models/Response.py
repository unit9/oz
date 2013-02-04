from webapp2_extras import json

class AppResponse:

    error = None
    result = True
    status = 200

    def set_error(self, error, status=400):
        self.error = error
        self.status = status

    def set_result(self, result):
        self.result = result

    def to_json(self):
        if self.error is not None:
            return json.encode({"error": self.error, "status": self.status})
        else:
            return json.encode({"result": self.result})
