<!-- development version, includes helpful console warnings -->
<link rel="stylesheet" type="text/css" href="${ctx.contextPath}/.resources/commenting-demo/webresources/css/comments.css" media="all" />
<script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
<script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>

<div class="container">
  <div class="row">
    <div class='col-xs-12'> <!-- TODO make it dynamic -->
      <h2>${content.title}</h2>
      <div id='comments'>
        <form @submit.prevent='addEntry()' id='commentForm'>
          <div v-if="ctxUser=='anonymous'" class="form-group">
              <label>Your name:</label>
              <input class="form-control" type='text' v-model='userId' required>
          </div>
          <div v-if="ctxUser=='anonymous'" class="form-group">
              <label>Your email:</label>
              <input class="form-control" type='email' v-model='userEmail'>
              Enter your email to receive notifications.
          </div>
          <div class="form-group">
              <label>Your comment:</label>
              <textarea class="form-control" rows="3" v-model='commentText' required></textarea>
          </div>
           <input type='submit' value='Add comment'  class="btn btn-default">
        </form>
        <hr>
        <br>
        <div v-for="(item, index) in commItems" v-if="item.abuseReport == false" class="comment">
          <div v-bind:id="'com_'+item.created">
            <div class="comment_header">
               <span v-if="item.authorChoice" class="comment_icon"><img src='${ctx.contextPath}/.resources/commenting-demo/webresources/img/star-blue.svg' width='26' height='26'></span>
              <b>{{item.userName}}</b> &nbsp; <span class="label label-primary">{{item.created | timestampToDate}}</span>
            </div>
            <div class="comment_body">
              {{ item.text }}
            </div>

            <div class="comment_actions">
              <!--<button ng-click='replyTo()' timestamp='{{item.timestamp}}' class="btn btn-default">Reply</button>-->
              <a @click.prevent='likeEntry(item)' href="#" class="comment_icon"><b>{{item.numLikes}}&nbsp;</b><img src='${ctx.contextPath}/.resources/commenting-demo/webresources/img/like.png' width='24' height='24'></a>
              <a @click.prevent='dislikeEntry(item)' href="#" class="comment_icon"><b>{{item.numUnlikes}}&nbsp;</b><img src='${ctx.contextPath}/.resources/commenting-demo/webresources/img/dislike.png' width='24' height='24'></a>
              <button @click='likeEntry(item)' v-bind:timestamp='item.created' class="btn btn-link">Like</button>
              <button @click='dislikeEntry(item)' v-bind:timestamp='item.created' class="btn btn-link">Dislike</button>
              <button @click='reportEntry(item)' v-bind:timestamp='item.created' class="btn btn-link">Report</button>
            </div>

          </div>
        </div>

      </div>
    </div>
  </div>
</div>

<script>

var app = new Vue({
  el: '#comments',
  data: {
      userId: '',
      userEmail: '',
      commentText: '',
      commItems: [],
      ctxUser: '',
  },
  mounted: function() {
    this.ctxUser = '${ctx.user.name!}';
    this.loadData();
  },
  methods: {
    addEntry: function () {
      axios.post('${ctx.contextPath}/.rest/commenting/v1/comment/', {
        "mgnlWorkspace": "website",
        "mgnlId": "${cmsfn.page(content).@id}",
        "text": this.commentText,
        "authorChoice": false,
        "abuseReport": false,
        "numLikes": 0,
        "numUnlikes": 0,
        "rating": 0,
        "userName": this.userId,
        "userEmail": this.userEmail
      }, {
        headers: {'Content-Type': 'application/json'}
      })
      .then(response => {
        console.log("form submit:", response);
        this.loadData();
      })
      .catch(error => console.log(error))
      .finally(() => {
        // resetting the form
        this.userId= '';
        this.userEmail= '';
        this.commentText= '';
      });

    },
    loadData: function() {
      axios.get('${ctx.contextPath}/.rest/commenting/v1/comments/website/${cmsfn.page(content).@id}')
      .then(response => {
        this.commItems = response.data;
        this.commItems.reverse();
        console.log("load comments:", response);
      })
      .catch(error => console.log(error));
    },
    likeEntry: function(item) {
      axios.post('${ctx.contextPath}/.rest/commenting/v1/like/'+item.id, {
        headers: {'Content-Type': 'application/json'}
      })
      .then(response => {
        console.log("liked:", response);
        this.loadData();
      })
      .catch(error => console.log(error));
    },
    dislikeEntry: function(item) {
      axios.post('${ctx.contextPath}/.rest/commenting/v1/dislike/'+item.id, {
        headers: {'Content-Type': 'application/json'}
      })
      .then(response => {
        console.log("disliked:", response);
        this.loadData();
      })
      .catch(error => console.log(error));
    },
    reportEntry: function(item) {
      axios.post('${ctx.contextPath}/.rest/commenting/v1/report/'+item.id, {
        headers: {'Content-Type': 'application/json'}
      })
      .then(response => {
        console.log("reported:", response);
        this.loadData();
      })
      .catch(error => console.log(error));
    }
  },
  filters: {
    timestampToDate: function (timestamp) {
      var date = new Date(timestamp);
      var now = new Date();
      var timeDiff = Math.abs(now-date);

      if (timeDiff/(1000*10) < 1){
          return "just now";
      } else if (timeDiff/(1000*60) < 1){
          return Math.round(timeDiff/(1000)) + " seconds ago";
      } else if (timeDiff/(1000*60*60) < 1){
          return Math.round(timeDiff/(1000*60)) + " minutes ago";
      } else if (timeDiff/(1000*60*60*24) < 1){
          return Math.round(timeDiff/(1000*60*60)) + " hours ago";
      } else if (timeDiff/(1000*60*60*24*1) < 1){
          return "yesterday at "+('0' + date.getHours()).slice(-2)+":"+('0' + date.getMinutes()).slice(-2);
      } else {
          return date.getDate() + "." + (date.getMonth() + 1)+ ". at "+('0' + date.getHours()).slice(-2)+":"+('0' + date.getMinutes()).slice(-2);
      }
    }
  }
});

</script>
