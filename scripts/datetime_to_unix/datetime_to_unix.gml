function datetime_to_unix(_datetime = date_current_datetime())
{
	return (_datetime - 25569) * 86400;
}