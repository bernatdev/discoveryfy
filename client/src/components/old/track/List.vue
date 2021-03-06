<template>
  <div>
    <q-ajax-bar
      ref="bar"
      position="top"
      color="accent"
      size="10px"
      skip-hijack
    />
    <q-toolbar class="q-my-md">
      <q-breadcrumbs class="q-mr-sm">
        <q-breadcrumbs-el
          icon="home"
          to="/"
        />
        <q-breadcrumbs-el
          v-for="(breadcrumb, idx) in breadcrumbList"
          :key="idx"
          :label="breadcrumb.label"
          :icon="breadcrumb.icon"
          :to="breadcrumb.to"
        />
      </q-breadcrumbs>
      <q-space />
      <div>
        <q-btn
          flat
          round
          dense
          icon="add"
          :to="{ name: 'TrackCreate' }"
        />
      </div>
    </q-toolbar>

    <q-table
      :data="items"
      :columns="columns"
      :pagination.sync="pagination"
      @request="onRequest"
      row-key="id"
      flat
    >
      <q-td
        slot="body-cell-action"
        slot-scope="props"
        :props="props"
      >
        <q-btn
          flat
          round
          dense
          color="secondary"
          :to="{ name: 'TrackShow', params: { id: props.row['@id'] } }"
          icon="format_align_justify"
        />
        <q-btn
          flat
          round
          dense
          color="secondary"
          :to="{ name: 'TrackUpdate', params: { id: props.row['@id'] } }"
          icon="edit"
        />
      </q-td>
    </q-table>
  </div>
</template>

<script>
import { mapActions, mapGetters } from 'vuex';

export default {
  created() {
    this.breadcrumbList = this.$route.meta.breadcrumb;
    this.onRequest({
      pagination: this.pagination,
      filter: undefined,
    });
  },

  data() {
    return {
      pagination: {
        // sortBy: 'name',
        // descending: false,
        page: 1, // page to be displayed
        rowsPerPage: 3, // maximum displayed rows
        rowsNumber: 10, // virtualy the max number of rows
      },
      columns: [
        { name: 'action' },
        { name: 'id', field: '@id', label: this.$t('id') },
        { name: 'spotify_uri', field: 'spotify_uri', label: this.$t('spotify_uri') },
        { name: 'youtube_uri', field: 'youtube_uri', label: this.$t('youtube_uri') },
        { name: 'artist', field: 'artist', label: this.$t('artist') },
        { name: 'name', field: 'name', label: this.$t('name') },
        { name: 'poll', field: 'poll', label: this.$t('poll') },
        { name: 'spotifyUri', field: 'spotifyUri', label: this.$t('spotifyUri') },
        { name: 'proposalDate', field: 'proposalDate', label: this.$t('proposalDate') },
      ],
      breadcrumbList: [],
      nextPage: null,
    };
  },

  watch: {
    isLoading(val) {
      if (val) {
        this.$refs.bar.start();
      } else {
        this.$refs.bar.stop();
      }
    },

    error(message) {
      message
        && this.$q.notify({
          message,
          color: 'red',
          icon: 'error',
          closeBtn: this.$t('Close'),
        });
    },

    items() {
      this.pagination.page = this.nextPage;
      this.nextPage = null;
    },

    deletedItem(val) {
      this.$q.notify({
        message: `${val['@id']} ${this.$t('deleted')}.`,
        color: 'green',
        icon: 'tag_faces',
        closeBtn: this.$t('Close'),
      });
    },

    totalItems(val) {
      this.pagination.rowsNumber = val;
    },
  },

  computed: mapGetters({
    deletedItem: 'track/del/deleted',
    error: 'track/list/error',
    items: 'track/list/items',
    isLoading: 'track/list/isLoading',
    view: 'track/list/view',
    totalItems: 'user/list/totalItems',
  }),

  methods: {
    ...mapActions({
      getPage: 'user/list/default',
    }),

    onRequest(props) {
      const { page, rowsPerPage } = props.pagination;
      this.nextPage = page;
      this.getPage({ params: { itemsPerPage: rowsPerPage, page } });
    },
  },
};
</script>
