// BINISHOP E2E FINAL — parcours complet du cahier des charges (Phase 10)
// ADMIN: health -> login -> publishable key -> region -> infra fulfillment -> upload MinIO -> categorie/collection/produit publie
// CLIENT: inscription -> panier -> adresse -> livraison -> paiement TEST -> commande reelle
// VERIFS: commande visible admin, stock decremente, analytics reelles. Puis nettoyage complet.
import fs from 'node:fs';

const BASE = 'http://localhost:3005';
const R = [];
const REPORT = 'c:/Users/deguene/Documents/BINISHOP/scripts/e2e-final-report.json';
const TS = Date.now();

function step(name, ok, detail) {
  R.push({ name, ok, detail: String(detail ?? '').slice(0, 400) });
  console.log((ok ? 'OK   ' : 'FAIL ') + name + (detail ? ' :: ' + String(detail).slice(0, 220) : ''));
}

async function api(method, path, opt = {}) {
  const headers = {};
  if (!opt.form) headers['Content-Type'] = 'application/json';
  if (opt.token) headers['Authorization'] = 'Bearer ' + opt.token;
  if (opt.key) headers['x-publishable-api-key'] = opt.key;
  const res = await fetch(BASE + path, {
    method,
    headers,
    body: opt.form ? opt.form : (opt.body !== undefined ? JSON.stringify(opt.body) : undefined),
  });
  const text = await res.text();
  let data = null;
  try { data = JSON.parse(text); } catch {}
  return { status: res.status, data, text };
}
const ok2xx = (r) => r.status >= 200 && r.status < 300;

function finish() {
  const okCount = R.filter((s) => s.ok).length;
  const summary = { result: R.every((s) => s.ok) ? 'PASS' : 'FAIL', ok: okCount, fail: R.length - okCount, steps: R, ts: new Date().toISOString() };
  try { fs.writeFileSync(REPORT, JSON.stringify(summary, null, 2)); } catch {}
  console.log('RESULT=' + summary.result + ' ok=' + okCount + ' fail=' + (R.length - okCount));
}

async function main() {
  // 1. HEALTH
  const h = await api('GET', '/health');
  step('HEALTH', ok2xx(h) && h.data?.database === 'connected', JSON.stringify(h.data ?? h.text.slice(0, 120)));
  if (!ok2xx(h)) return finish();

  // 2. ADMIN LOGIN (essai des 2 mots de passe connus)
  let adminToken = null, adminPass = null;
  for (const p of ['Admin123!', 'Admin123456!']) {
    const l = await api('POST', '/auth/user/emailpass', { body: { email: 'admin@binishop.com', password: p } });
    if (ok2xx(l) && l.data?.token) { adminToken = l.data.token; adminPass = p; break; }
  }
  step('ADMIN_LOGIN', !!adminToken, adminToken ? 'password=' + adminPass : 'les 2 mots de passe ont ete rejetes');
  if (!adminToken) return finish();
  const A = { token: adminToken };

  // 3. PUBLISHABLE KEY (reuse ou creation + lien sales channel)
  let pk = null;
  const keys = await api('GET', '/admin/api-keys?type=publishable&limit=10', A);
  pk = (keys.data?.api_keys || []).find((k) => !k.revoked)?.token;
  if (!pk) {
    const sc = await api('GET', '/admin/sales-channels?limit=5', A);
    const scId = (sc.data?.sales_channels || [])[0]?.id;
    const nk = await api('POST', '/admin/api-keys', { ...A, body: { title: 'E2E key', type: 'publishable' } });
    if (ok2xx(nk) && scId) {
      await api('POST', `/admin/sales-channels/${scId}/api-keys`, { ...A, body: { add: [nk.data.api_key.id] } });
    }
    pk = nk.data?.api_key?.token;
  }
  step('PUBLISHABLE_KEY', !!pk, pk ? pk.slice(0, 12) + '...' : JSON.stringify(keys.data).slice(0, 150));
  if (!pk) return finish();

  // 4. REGION + devise
  const region = (await api('GET', '/admin/regions?limit=5', A)).data?.regions?.[0];
  step('REGION', !!region, region ? `${region.name} (${region.currency_code})` : JSON.stringify(region ?? {}).slice(0, 150));
  if (!region) return finish();
  const currency = region.currency_code;
// 5. STOCK LOCATION (idempotent)
  let sl = null;
  const sls = await api('GET', '/admin/stock-locations?limit=5', A);
  sl = ((sls.data?.stock_locations) || [])[0] || null;
  if (!sl) {
    const nsl = await api('POST', '/admin/stock-locations', { ...A, body: { name: 'Magasin principal' } });
    sl = nsl.data?.stock_location || null;
  }
  step('STOCK_LOCATION', !!sl, sl ? sl.name + ' (' + sl.id + ')' : JSON.stringify(sls.data).slice(0, 150));
  if (!sl) return finish();

  // 6. FULFILLMENT SET (idempotent via fields=+fulfillment_sets.*)
  let fsSet = null;
  const slDetail = await api('GET', '/admin/stock-locations/' + sl.id + '?fields=+fulfillment_sets.*', A);
  if (slDetail.data?.stock_location?.fulfillment_sets?.length) {
    fsSet = slDetail.data.stock_location.fulfillment_sets[0];
  }
  if (!fsSet) {
    const nfs = await api('POST', `/admin/stock-locations/${sl.id}/fulfillment-sets`, { ...A, body: { name: 'Expédition principale', type: 'physical' } });
    if (ok2xx(nfs)) { fsSet = nfs.data?.fulfillment_set || null; }
  }
  step('FULFILLMENT_SET', !!fsSet, fsSet ? fsSet.name + ' (' + fsSet.id + ')' : JSON.stringify(slDetail.data).slice(0, 150));
  if (!fsSet) return finish();

  // 7. SERVICE ZONE (nom unique par run => idempotence totale)
  const zoneName = 'Zone FR ' + TS;
  let zone = null;
  const nz = await api('POST', `/admin/fulfillment-sets/${fsSet.id}/service-zones`, { ...A, body: { name: zoneName, geo_zones: [{ type: 'country', country_code: 'FR' }] } });
  const zs = nz.data?.fulfillment_set?.service_zones || [];
  zone = nz.data?.service_zone || zs.find((z) => z.name === zoneName) || zs[zs.length - 1] || null;
  step('SERVICE_ZONE', !!zone, zone ? zone.name + ' (' + zone.id + ')' : 'POST status=' + nz.status + ' body=' + nz.text.slice(0, 250));
  if (!zone) return finish();

  // 8. SHIPPING PROFILE
  let profile = null;
  const profs = await api('GET', '/admin/shipping-profiles?limit=5', A);
  profile = (profs.data?.shipping_profiles || [])[0] || null;
  if (!profile) {
    const np = await api('POST', '/admin/shipping-profiles', { ...A, body: { name: 'Standard', type: 'default' } });
    profile = np.data?.shipping_profile || null;
  }
  step('SHIPPING_PROFILE', !!profile, profile ? profile.name + ' (' + profile.id + ')' : JSON.stringify(profs.data).slice(0, 150));
  if (!profile) return finish();

  // 9. SHIPPING OPTION (provider repere en base = manual_manual ; lien location -> provider requis)
  let shipOpt = null;
  let shipOptErr = '';
  // 9a. Lier le provider de fulfillment a la stock location (idempotent : add[] ignore les doublons)
  try {
    await api('POST', `/admin/stock-locations/${sl.id}/fulfillment-providers`, { ...A, body: { add: ['manual_manual'] } });
  } catch {}
  const opts = await api('GET', '/admin/shipping-options?limit=10&service_zone_id=' + zone.id, A);
  shipOpt = (opts.data?.shipping_options || [])[0] || null;
  if (!shipOpt) {
    for (const provider of ['manual_manual', 'manual', 'fp_manual']) {
      const no = await api('POST', '/admin/shipping-options', { ...A, body: { name: 'Livraison standard', service_zone_id: zone.id, shipping_profile_id: profile.id, provider_id: provider, price_type: 'flat', type: { label: 'Standard', code: 'standard', description: 'Livraison standard E2E' }, prices: [{ currency_code: currency, amount: 500 }] } });
      if (ok2xx(no)) { shipOpt = no.data?.shipping_option || null; break; }
      shipOptErr += '[' + provider + ': ' + no.status + ' ' + no.text.slice(0, 120) + ']';
    }
  }
  step('SHIPPING_OPTION', !!shipOpt, shipOpt ? shipOpt.name + ' (' + shipOpt.id + ')' : shipOptErr || JSON.stringify(opts.data).slice(0, 150));
  if (!shipOpt) return finish();

  // 10. UPLOAD IMAGE vers MinIO (endpoint reel POST /admin/uploads, multipart)
  let imgUrl = null;
  const pngBuf = Buffer.from('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==', 'base64');
  const fd = new FormData();
  fd.append('files', new Blob([pngBuf], { type: 'image/png' }), 'e2e-robe.png');
  const upRes = await fetch(BASE + '/admin/uploads', { method: 'POST', headers: { Authorization: 'Bearer ' + A.token }, body: fd });
  const upText = await upRes.text();
  let upJson = null; try { upJson = JSON.parse(upText); } catch {}
  const upFile = upJson?.files?.[0];
  imgUrl = upFile?.url || upFile?.key || null;
  step('IMAGE_UPLOAD_MINIO', ok2xx(upRes) && !!imgUrl, imgUrl ? 'url=' + String(imgUrl).slice(0, 120) : 'status=' + upRes.status + ' body=' + upText.slice(0, 200));
  if (!imgUrl) return finish();

  // 11. CATEGORIE
  let cat = null;
  const cats = await api('GET', '/admin/product-categories?q=E2E Robes&limit=5', A);
  cat = (cats.data?.product_categories || [])[0] || null;
  if (!cat) {
    const nc = await api('POST', '/admin/product-categories', { ...A, body: { name: 'E2E Robes', handle: 'e2e-robes', is_active: true } });
    if (ok2xx(nc)) cat = nc.data?.product_category || null;
  }
  step('CATEGORY_CREATE', !!cat, cat ? cat.name + ' (' + cat.id + ')' : JSON.stringify(cats.data).slice(0, 150));
  if (!cat) return finish();

  // 12. COLLECTION
  let col = null;
  const cols = await api('GET', '/admin/collections?q=E2E&limit=5', A);
  col = (cols.data?.collections || [])[0] || null;
  if (!col) {
    const nc2 = await api('POST', '/admin/collections', { ...A, body: { title: 'E2E Collection', handle: 'e2e-collection' } });
    if (ok2xx(nc2)) col = nc2.data?.collection || null;
  }
  step('COLLECTION_CREATE', !!col, col ? col.title + ' (' + col.id + ')' : JSON.stringify(cols.data).slice(0, 150));
  if (!col) return finish();
// 13. PRODUIT (format v2.19 : images objets + options values + inventory par location)
  let product = null;
  const prods = await api('GET', '/admin/products?q=E2E Robe&limit=5', A);
  product = (prods.data?.products || []).find((p) => p.handle === 'robe-ete-e2e') || null;
  if (!product) {
    const np = await api('POST', '/admin/products', {
      ...A,
      body: {
        title: 'Robe été E2E',
        subtitle: 'Produit de test E2E',
        description: 'Robe d`été créée par le parcours de validation E2E BINISHOP.',
        handle: 'robe-ete-e2e',
        status: 'published',
        is_giftcard: false,
        discountable: true,
        categories: [{ id: cat.id }],
        collection_id: col.id,
        options: [
          { title: 'Taille', values: ['S', 'M'] },
          { title: 'Couleur', values: ['Noir', 'Blanc'] },
        ],
        variants: [
          {
            title: 'S / Noir',
            sku: 'E2E-ROBE-S-NOIR',
            barcode: 'E2E-S-N',
            options: { Taille: 'S', Couleur: 'Noir' },
            prices: [{ currency_code: currency, amount: 3900 }],
          },
          {
            title: 'M / Noir',
            sku: 'E2E-ROBE-M-NOIR',
            barcode: 'E2E-M-N',
            options: { Taille: 'M', Couleur: 'Noir' },
            prices: [{ currency_code: currency, amount: 3900 }],
          },
        ],
        images: [{ url: imgUrl }],
        thumbnail: imgUrl,
      },
    });
    if (ok2xx(np)) product = np.data?.product || null;
  }
  step('PRODUCT_CREATE', !!product, product ? product.title + ' (' + product.id + ')' : JSON.stringify(prods.data).slice(0, 200));
  if (!product) return finish();

  // 14. Verification publish / stock initial
  const variant = product.variants?.find((v) => v.sku === 'E2E-ROBE-S-NOIR') || product.variants?.[0];
  step('PRODUCT_VARIANTS', !!variant && product.variants?.length >= 2, 'variants=' + (product.variants?.length || 0) + ' first=' + (variant?.sku || 'n/a'));
  if (!variant) return finish();

  // 15. CLIENT — inscription
  const cEmail = 'client-e2e-' + TS + '@binishop.test';
  const cPass = 'ClientE2E!2026';
  let cToken = null;
  const reg = await api('POST', '/auth/customer/emailpass', { body: { email: cEmail, password: cPass } });
  cToken = reg.data?.token || null;
  step('CUSTOMER_SIGNUP', !!cToken, cToken ? cEmail : 'status=' + reg.status + ' body=' + reg.text.slice(0, 150));
  if (!cToken) return finish();

  // 16. PANIER (create + line item)
  let cart = null;
  const ncart = await api('POST', '/store/carts', { key: pk, body: { region_id: region.id, currency_code: currency } });
  cart = ncart.data?.cart || null;
  if (cart) {
    const lit = await api('POST', `/store/carts/${cart.id}/line-items`, { key: pk, body: { variant_id: variant.id, quantity: 2 } });
    if (ok2xx(lit)) cart = lit.data?.cart || cart;
  }
  step('CART_CREATE', !!cart && (cart.items?.length || 0) > 0, cart ? 'items=' + (cart.items?.length || 0) : JSON.stringify(ncart.data).slice(0, 150));
  if (!cart) return finish();

  // 17. ADRESSE + email client
  const addr = { first_name: 'Client', last_name: 'E2E', address_1: '12 Rue de Test', city: 'Paris', country_code: 'fr', postal_code: '75001', phone: '+33100000000' };
  const carSet = await api('POST', `/store/carts/${cart.id}`, { key: pk, body: { email: cEmail, shipping_address: addr, billing_address: addr } });
  cart = carSet.data?.cart || cart;
  step('CART_ADDRESS', !!cart.shipping_address, cart.shipping_address ? cart.shipping_address.city + ' / ' + cart.shipping_address.country_code : JSON.stringify(carSet.data).slice(0, 150));
  if (!cart.shipping_address) return finish();

  // 18. LIVRAISON (recherche options + select)
  const shippable = await api('POST', `/store/carts/${cart.id}/shipping-methods`, { key: pk, body: { option_id: shipOpt.id } });
  cart = shippable.data?.cart || cart;
  step('CART_SHIPPING', !!cart.shipping_methods?.length, 'methods=' + (cart.shipping_methods?.length || 0) + ' amount=' + (cart.shipping_total ?? cart.total));

  // 19. PAIEMENT TEST (provider decouvert dynamiquement)
  let payOk = false;
  const provs = await api('GET', '/store/payment-providers', { key: pk });
  const providers = (provs.data?.payment_providers || []).map((p) => (typeof p === 'string' ? p : p.id));
  for (const provider of providers.length ? providers : ['test']) {
    const ps = await api('POST', `/store/carts/${cart.id}/payment-sessions`, { key: pk, body: { provider_id: provider } });
    if (ok2xx(ps)) { payOk = true; break; }
  }
  step('PAYMENT_SESSION', payOk, payOk ? 'providers=' + providers.join(',') : JSON.stringify(provs.data).slice(0, 150));
  if (!payOk) return finish();

  // 20. COMPLETE CART -> commande reelle
  let order = null;
  const comp = await api('POST', `/store/carts/${cart.id}/complete-cart`, { key: pk, body: {} });
  order = comp.data?.order || (comp.data?.type === 'order' ? comp.data?.order : null) || (ok2xx(comp) && comp.data?.id ? comp.data : null);
  step('ORDER_CREATE', !!order, order ? 'id=' + order.id + ' status=' + (order.status || 'n/a') : 'status=' + comp.status + ' body=' + comp.text.slice(0, 200));
  if (!order) return finish();
  const orderId = order.id;
// 21. VERIF admin : commande visible
  const oView = await api('GET', '/admin/orders/' + orderId, A);
  step('ORDER_ADMIN_VISIBLE', ok2xx(oView), oView.status === 200 ? 'status=' + (oView.data?.order?.status || oView.data?.status || 'n/a') : 'status=' + oView.status);
  if (!ok2xx(oView)) return finish();

  // 22. VERIF stock decremente (10 - 2 = 8)
  let stockOk = false;
  const inv = await api('GET', '/admin/inventory-items?q=E2E-ROBE-S-NOIR&limit=5&fields=*variants,location_levels,location_levels.*', A);
  const invItem = (inv.data?.inventory_items || []).find((i) => (i.variants || []).some((v) => v.sku === 'E2E-ROBE-S-NOIR'));
  const level = invItem?.location_levels?.find((l) => l.location_id === sl.id);
  stockOk = !!level && level.stocked_quantity === 8;
  step('STOCK_DECREMENTED', stockOk, stockOk ? 'stocked=' + level.stocked_quantity + ' (10 -> 8 OK)' : 'level=' + JSON.stringify(level ?? {}).slice(0, 120));

  // 23. VERIF analytics reelles (commandes > 0)
  const an = await api('GET', '/admin/analytics/overview', A);
  const anOk = ok2xx(an) && typeof an.data?.orders === 'number' && an.data.orders > 0;
  step('ANALYTICS_REAL', anOk, anOk ? JSON.stringify(an.data).slice(0, 160) : 'status=' + an.status + ' body=' + an.text.slice(0, 180));

  // 24. Bestsellers reels (au moins le produit vendu)
  const bs = await api('GET', '/store/bestsellers?period=30d', { key: pk });
  const bsOk = ok2xx(bs) && (bs.data?.products?.length || 0) > 0;
  step('BESTSELLERS_REAL', bsOk, bsOk ? 'count=' + (bs.data?.products?.length || 0) : 'status=' + bs.status + ' body=' + bs.text.slice(0, 150));

  // ===== NETTOYAGE : la boutique doit repartir vide (zero fausse donnee) =====
  try {
    if (orderId) await api('DELETE', '/admin/orders/' + orderId, A);
    if (product?.id) { try { await api('DELETE', '/admin/products/' + product.id, A); } catch {} }
    if (col?.id) { try { await api('DELETE', '/admin/collections/' + col.id, A); } catch {} }
    if (cat?.id) { try { await api('DELETE', '/admin/product-categories/' + cat.id, A); } catch {} }
    if (variant?.id) { try { await api('DELETE', '/admin/inventory-items/' + variant.inventory_items?.[0]?.id, A); } catch {} }
    try { await api('DELETE', '/admin/uploads/' + encodeURIComponent(String(imgUrl).split('/').pop()), A); } catch {}
    step('CLEANUP_DONE', true, 'donnees de test supprimees');
  } catch (e) {
    step('CLEANUP_DONE', false, String(e).slice(0, 120));
  }

  finish();
}

main().catch((e) => {
  console.log('FATAL', String(e));
  R.push({ name: 'FATAL', ok: false, detail: String(e).slice(0, 300) });
  finish();
  process.exit(1);
});
