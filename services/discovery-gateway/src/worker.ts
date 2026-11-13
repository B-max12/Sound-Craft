import { handleWorkerRequest, type Env } from './gateway.js';

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    return handleWorkerRequest(request, env);
  },
};
